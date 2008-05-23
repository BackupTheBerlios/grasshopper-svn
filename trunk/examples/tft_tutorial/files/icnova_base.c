/*
 * init code specific for ICNova Base
 *
 * Copyright (C) 2005-2006 Atmel Corporation
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */
#include <linux/bootmem.h>
#include <linux/linkage.h>
#include <linux/clk.h>
#include <linux/etherdevice.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/platform_device.h>
#include <linux/string.h>
#include <linux/types.h>
#include <linux/spi/spi.h>

#include <asm/io.h>
#include <asm/setup.h>
#include <asm/arch/at32ap700x.h>
#include <asm/arch/board.h>
#include <asm/arch/init.h>
#include <asm/arch/portmux.h>

#include "icnova.h"
#include "led.h"
#include "btn.h"
#include "mac.h"
#include "pwm.h"

#include <linux/fb.h>
#include <video/atmel_lcdc.h>


#undef ICNOVA_USB_CP2102

static struct fb_videomode grasshopper_tft_modes[] = { 
	{ 
	       	.name        	= "TX09D70 @ 60", 	// name of mode
		.refresh	= 60, 			// refresh rate 
		.xres		= 240,			// horizontal resolution 
		.yres		= 320, 			// vertical resolution 
		.pixclock	= KHZ2PICOS(4965), 	// pixel clock in kHz 
		.left_margin	= 1,			// h. front porch 
		.right_margin	= 33, 			// h. back porch 
		.upper_margin	= 1,			// v. front porch 
		.lower_margin	= 0, 			// v. back porch 
		.hsync_len	= 5,			// hsync length  
		.vsync_len	= 1, 			// vsync lengt 
		.sync		= FB_SYNC_HOR_HIGH_ACT | FB_SYNC_VERT_HIGH_ACT,
				// Active high hsync impulse , active high vsync impulse  
		.vmode		= FB_VMODE_NONINTERLACED, 
				// always send a full frame to the display 
	}, 
}; 

static struct fb_monspecs __initdata grasshopper_default_monspecs = { 
        .manufacturer           = "ATM", 		// ATM = Atmel 
        .monitor                = "GENERIC",  		// Generic type 
        .modedb                 = grasshopper_tft_modes, 
        .modedb_len             = ARRAY_SIZE(grasshopper_tft_modes), 
        .hfmin                  = 14820, 		// doesn't affect the lcdc! 
        .hfmax                  = 32000, 		// doesn't affect the lcdc! 
        .vfmin                  = 30, 			// doesn't affect the lcdc! 
        .vfmax                  = 200, 			// doesn't affect the lcdc! 
        .dclkmax                = 30000000, 		// doesn't affect the lcdc! 
}; 

 struct atmel_lcdfb_info __initdata grasshopper_lcdc_data = { 
        .default_bpp            = 16, 			// Color depth
        .default_dmacon         = ATMEL_LCDC_DMAEN | ATMEL_LCDC_DMA2DEN, 
        .default_lcdcon2        = (ATMEL_LCDC_DISTYPE_TFT 
                                   | ATMEL_LCDC_CLKMOD_ALWAYSACTIVE 
                                   | ATMEL_LCDC_MEMOR_BIG), 
        .default_monspecs       = &grasshopper_default_monspecs, 
        .guard_time             = 2, 
};


void __init setup_board(void)
{
	at32_map_usart(0, 0);	// USART 0: /dev/ttyS0, IF-to-USB-UART_Bridge
#ifdef ICNOVA_USB_CP2102
	at32_map_usart(1, 1);	// USART 1: /dev/ttyS0, CP2102
#endif

	at32_setup_serial_console(0);
}

static int __init icnova_init(void)
{

	icnova_reserve_pins();

	at32_add_system_devices();

	at32_add_device_usart(0);
#ifdef ICNOVA_USB_CP2102
	at32_add_device_usart(1);
#endif

	at32_add_device_pwm((1<<2));
	icnova_setup_pwm(2,25000000); // 25MHz

	icnova_setup_leds();
	icnova_setup_buttons();

	set_hw_addr(at32_add_device_eth(0, &eth_data[0]));

	at32_add_device_twi(0,NULL,0); // Nothing yet on I2C
	at32_add_device_usba(0, NULL);
	at32_add_device_lcdc(0, &grasshopper_lcdc_data, fbmem_start, fbmem_size);

	return 0;
}
postcore_initcall(icnova_init);
