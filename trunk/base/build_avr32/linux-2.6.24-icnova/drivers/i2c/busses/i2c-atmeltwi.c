/*
 * i2c Support for Atmel's Two-Wire Interface (TWI)
 *
 * Based on the work of Copyright (C) 2004 Rick Bronson
 * Converted to 2.6 by Andrew Victor <andrew at sanpeople.com>
 * Ported to AVR32 and heavily modified by Espen Krangnes
 * <ekrangnes at atmel.com>
 *
 * Copyright (C) 2006 Atmel Corporation
 *
 * Borrowed heavily from the original work by:
 * Copyright (C) 2000 Philip Edelbrock <phil at stimpy.netroedge.com>
 *
 * Partialy rewriten by Karel Hojdar <cmkaho at seznam.cz>
 * bugs removed, interrupt routine markedly rewritten
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */
#undef VERBOSE_DEBUG

#include <linux/module.h>
#include <linux/slab.h>
#include <linux/i2c.h>
#include <linux/init.h>
#include <linux/clk.h>
#include <linux/err.h>
#include <linux/interrupt.h>
#include <linux/platform_device.h>
#include <linux/completion.h>
#include <linux/io.h>

#include "i2c-atmeltwi.h"

static unsigned int baudrate = 100 * 1000;
module_param(baudrate, uint, S_IRUGO);
MODULE_PARM_DESC(baudrate, "The TWI baudrate");


struct atmel_twi {
	void __iomem *regs;
	struct i2c_adapter adapter;
	struct clk *pclk;
	struct completion comp;
	u32 mask;
	u8 *buf;
	u16 len;
	u16 acks_left;
	int status;
	unsigned int irq;

};
#define to_atmel_twi(adap) container_of(adap, struct atmel_twi, adapter)

/*
 * (Re)Initialize the TWI hardware registers.
 */
static int twi_hwinit(struct atmel_twi *twi)
{
	unsigned long cdiv, ckdiv = 0;

	/* REVISIT: wait till SCL is high before resetting; otherwise,
	 * some versions will wedge forever.
	 */

	twi_writel(twi, IDR, ~0UL);
	twi_writel(twi, CR, TWI_BIT(SWRST));	/*Reset peripheral*/
	twi_readl(twi, SR);

	cdiv = (clk_get_rate(twi->pclk) / (2 * baudrate)) - 4;

	while (cdiv > 255) {
		ckdiv++;
		cdiv = cdiv >> 1;
	}

	/* REVISIT: there are various errata to consider re CDIV and CHDIV
	 * here, at least on at91 parts.
	 */

	if (ckdiv > 7)
		return -EINVAL;
	else
		twi_writel(twi, CWGR, TWI_BF(CKDIV, ckdiv)
				| TWI_BF(CHDIV, cdiv)
				| TWI_BF(CLDIV, cdiv));
	return 0;
}

/*
 * Waits for the i2c status register to set the specified bitmask
 * Returns 0 if timed out ... ~100ms is much longer than the SMBus
 * limit, but I2C has no limit at all.
 */
static int twi_complete(struct atmel_twi *twi, u32 mask)
{
	int timeout = msecs_to_jiffies(100);

	mask |= TWI_BIT(TXCOMP);
	twi->mask = mask | TWI_BIT(NACK) | TWI_BIT(OVRE);
	init_completion(&twi->comp);

	twi_writel(twi, IER, mask);

	if (!wait_for_completion_timeout(&twi->comp, timeout)) {
		/* RESET TWI interface */
		twi_writel(twi, CR, TWI_BIT(SWRST));

		/* Reinitialize TWI */
		twi_hwinit(twi);

		return -ETIMEDOUT;
	}
	return 0;
}

/*
 * Generic i2c master transfer entrypoint.
 */
static int twi_xfer(struct i2c_adapter *adap, struct i2c_msg *pmsg, int num)
{
	struct atmel_twi *twi = to_atmel_twi(adap);
	int i;

	dev_dbg(&adap->dev, "twi_xfer: processing %d messages:\n", num);

	twi->status = 0;
	for (i = 0; i < num; i++, pmsg++) {
		twi->len = pmsg->len;
		twi->buf = pmsg->buf;
		twi->acks_left = pmsg->len;
		twi_writel(twi, MMR, TWI_BF(DADR, pmsg->addr) |
			(pmsg->flags & I2C_M_RD ? TWI_BIT(MREAD) : 0));
		twi_writel(twi, IADR, TWI_BF(IADR, pmsg->addr));

		dev_dbg(&adap->dev,
			"#%d: %s %d byte%s %s dev 0x%02x\n",
			i,
			pmsg->flags & I2C_M_RD ? "reading" : "writing",
			pmsg->len,
			pmsg->len > 1 ? "s" : "",
			pmsg->flags & I2C_M_RD ? "from" : "to", pmsg->addr);

		/* enable */
		twi_writel(twi, CR, TWI_BIT(MSEN));

		if (pmsg->flags & I2C_M_RD) {
			/* cleanup after previous RX overruns */
			while (twi_readl(twi, SR) & TWI_BIT(RXRDY))
				twi_readl(twi, RHR);

			if (twi->len == 1)
				twi_writel(twi, CR,
					TWI_BIT(START) | TWI_BIT(STOP));
			else
				twi_writel(twi, CR, TWI_BIT(START));

			if (twi_complete(twi, TWI_BIT(RXRDY)) == -ETIMEDOUT) {
				dev_dbg(&adap->dev, "RX[%d] timeout. "
					"Stopped with %d bytes left\n",
					i, twi->acks_left);
				return -ETIMEDOUT;
			}
		} else {
			twi_writel(twi, THR, twi->buf[0]);
			twi->acks_left--;
			/* REVISIT: some chips don't start automagically:
			 * twi_writel(twi, CR, TWI_BIT(START));
			 */
			if (twi_complete(twi, TWI_BIT(TXRDY)) == -ETIMEDOUT) {
				dev_dbg(&adap->dev, "TX[%d] timeout. "
					"Stopped with %d bytes left\n",
					i, twi->acks_left);
				return -ETIMEDOUT;
			}
			/* REVISIT: an erratum workaround may be needed here;
			 * see sam9261 "STOP not generated" (START either).
			 */
		}

		/* Disable TWI interface */
		twi_writel(twi, CR, TWI_BIT(MSDIS));

		if (twi->status)
			return twi->status;

		/* WARNING:  This driver lies about properly supporting
		 * repeated start, or it would *ALWAYS* return here.  It
		 * has issued a STOP.  Continuing is a false claim -- that
		 * a second (or third, etc.) message is part of the same
		 * "combined" (no STOPs between parts) message.
		 */

	} /* end cur msg */

	return i;
}


static irqreturn_t twi_interrupt(int irq, void *dev_id)
{
	struct atmel_twi *twi = dev_id;
	int status = twi_readl(twi, SR);

	/* Save state for later debug prints */
	int old_status = status;

	if (twi->mask & status) {

		status &= twi->mask;

		if (status & TWI_BIT(RXRDY)) {
			if ((status & TWI_BIT(OVRE)) && twi->acks_left) {
				/* Note weakness in fault reporting model:
				 * we can't say "the first N of these data
				 * bytes are valid".
				 */
				dev_err(&twi->adapter.dev,
					"OVERRUN RX! %04x, lost %d\n",
					old_status, twi->acks_left);
				twi->acks_left = 0;
				twi_writel(twi, CR, TWI_BIT(STOP));
				twi->status = -EOVERFLOW;
			} else if (twi->acks_left > 0) {
				twi->buf[twi->len - twi->acks_left] =
					twi_readl(twi, RHR);
				twi->acks_left--;
			}
			if (status & TWI_BIT(TXCOMP))
				goto done;
			if (twi->acks_left == 1)
				twi_writel(twi, CR, TWI_BIT(STOP));

		} else if (status & (TWI_BIT(NACK) | TWI_BIT(TXCOMP))) {
			goto done;

		} else if (status & TWI_BIT(TXRDY)) {
			if (twi->acks_left > 0) {
				twi_writel(twi, THR,
					twi->buf[twi->len - twi->acks_left]);
				twi->acks_left--;
			} else
				twi_writel(twi, CR, TWI_BIT(STOP));
		}

		if (twi->acks_left == 0)
			twi_writel(twi, IDR, ~TWI_BIT(TXCOMP));
	}

	/* enabling this message helps trigger overruns/underruns ... */
	dev_vdbg(&twi->adapter.dev,
		"ISR: SR 0x%04X, mask 0x%04X, acks %i\n",
		old_status,
		twi->acks_left ? twi->mask : TWI_BIT(TXCOMP),
		twi->acks_left);

	return IRQ_HANDLED;

done:
	/* Note weak fault reporting model:  we can't report how many
	 * bytes we sent before the NAK, or let upper layers choose
	 * whether to continue.  The I2C stack doesn't allow that...
	 */
	if (status & TWI_BIT(NACK)) {
		dev_dbg(&twi->adapter.dev, "NACK received! %d to go\n",
			twi->acks_left);
		twi->status = -EPIPE;

	/* TX underrun morphs automagically into a premature STOP;
	 * we'll probably observe UVRE even when it's not documented.
	 */
	} else if (twi->acks_left && (twi->mask & TWI_BIT(TXRDY))) {
		dev_err(&twi->adapter.dev, "UNDERRUN TX!  %04x, %d to go\n",
			old_status, twi->acks_left);
		twi->status = -ENOSR;
	}

	twi_writel(twi, IDR, ~0UL);
	complete(&twi->comp);

	dev_dbg(&twi->adapter.dev, "ISR: SR 0x%04X, acks %i --> %d\n",
		old_status, twi->acks_left, twi->status);

	return IRQ_HANDLED;
}


/*
 * Return list of supported functionality.
 *
 * NOTE:  see warning above about repeated starts; this driver is falsely
 * claiming to support "combined" transfers.  The mid-message STOPs mean
 * some slaves will never work with this driver.  (Use i2c-gpio...)
 */
static u32 twi_func(struct i2c_adapter *adapter)
{
	return (I2C_FUNC_I2C | I2C_FUNC_SMBUS_EMUL)
		& ~I2C_FUNC_SMBUS_QUICK;
}

static struct i2c_algorithm twi_algorithm = {
	.master_xfer	= twi_xfer,
	.functionality	= twi_func,
};

/*
 * Main initialization routine.
 */
static int __init twi_probe(struct platform_device *pdev)
{
	struct atmel_twi *twi;
	struct resource *regs;
	struct clk *pclk;
	struct i2c_adapter *adapter;
	int rc, irq;

	regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if (!regs)
		return -ENXIO;

	pclk = clk_get(&pdev->dev, "twi_pclk");
	if (IS_ERR(pclk))
		return PTR_ERR(pclk);
	clk_enable(pclk);

	rc = -ENOMEM;
	twi = kzalloc(sizeof(struct atmel_twi), GFP_KERNEL);
	if (!twi) {
		dev_dbg(&pdev->dev, "can't allocate interface!\n");
		goto err_alloc_twi;
	}

	twi->pclk = pclk;
	twi->regs = ioremap(regs->start, regs->end - regs->start + 1);
	if (!twi->regs)
		goto err_ioremap;

	irq = platform_get_irq(pdev, 0);
	rc = request_irq(irq, twi_interrupt, 0, "twi", twi);
	if (rc) {
		dev_dbg(&pdev->dev, "can't bind irq!\n");
		goto err_irq;
	}
	twi->irq = irq;

	rc = twi_hwinit(twi);
	if (rc) {
		dev_err(&pdev->dev, "Unable to set baudrate\n");
		goto err_hw_init;
	}

	adapter = &twi->adapter;
	sprintf(adapter->name, "TWI");
	adapter->algo = &twi_algorithm;
	adapter->class = I2C_CLASS_ALL;
	adapter->nr = pdev->id;
	adapter->dev.parent = &pdev->dev;

	platform_set_drvdata(pdev, twi);

	rc = i2c_add_numbered_adapter(adapter);
	if (rc) {
		dev_dbg(&pdev->dev, "Adapter %s registration failed\n",
			adapter->name);
		goto err_register;
	}

	dev_info(&pdev->dev,
		"Atmel TWI/I2C adapter (baudrate %dk) at 0x%08lx.\n",
		 baudrate/1000, (unsigned long)regs->start);

	return 0;


err_register:
	platform_set_drvdata(pdev, NULL);

err_hw_init:
	free_irq(irq, twi);

err_irq:
	iounmap(twi->regs);

err_ioremap:
	kfree(twi);

err_alloc_twi:
	clk_disable(pclk);
	clk_put(pclk);

	return rc;
}

static int __exit twi_remove(struct platform_device *pdev)
{
	struct atmel_twi *twi = platform_get_drvdata(pdev);
	int res;

	platform_set_drvdata(pdev, NULL);
	res = i2c_del_adapter(&twi->adapter);
	twi_writel(twi, CR, TWI_BIT(MSDIS));
	iounmap(twi->regs);
	clk_disable(twi->pclk);
	clk_put(twi->pclk);
	free_irq(twi->irq, twi);
	kfree(twi);

	return res;
}

static struct platform_driver twi_driver = {
	.remove		= __exit_p(twi_remove),
	.driver		= {
		.name	= "atmel_twi",
		.owner	= THIS_MODULE,
	},
};

static int __init atmel_twi_init(void)
{
	return platform_driver_probe(&twi_driver, twi_probe);
}

static void __exit atmel_twi_exit(void)
{
	platform_driver_unregister(&twi_driver);
}

module_init(atmel_twi_init);
module_exit(atmel_twi_exit);

MODULE_AUTHOR("Espen Krangnes");
MODULE_DESCRIPTION("I2C driver for Atmel TWI");
MODULE_LICENSE("GPL");
