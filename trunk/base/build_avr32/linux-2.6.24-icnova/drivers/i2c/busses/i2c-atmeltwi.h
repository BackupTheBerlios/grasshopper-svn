/*
 * Register definitions for the Atmel Two-Wire Interface
 */

#ifndef __ATMELTWI_H__
#define __ATMELTWI_H__

/* TWI register offsets */
#define TWI_CR					0x0000
#define TWI_MMR					0x0004
#define TWI_SMR					0x0008
#define TWI_IADR				0x000c
#define TWI_CWGR				0x0010
#define TWI_SR					0x0020
#define TWI_IER					0x0024
#define TWI_IDR					0x0028
#define TWI_IMR					0x002c
#define TWI_RHR					0x0030
#define TWI_THR					0x0034

/* Bitfields in CR */
#define TWI_START_OFFSET			0
#define TWI_START_SIZE				1
#define TWI_STOP_OFFSET				1
#define TWI_STOP_SIZE				1
#define TWI_MSEN_OFFSET				2
#define TWI_MSEN_SIZE				1
#define TWI_MSDIS_OFFSET			3
#define TWI_MSDIS_SIZE				1
#define TWI_SVEN_OFFSET				4
#define TWI_SVEN_SIZE				1
#define TWI_SVDIS_OFFSET			5
#define TWI_SVDIS_SIZE				1
#define TWI_SWRST_OFFSET			7
#define TWI_SWRST_SIZE				1

/* Bitfields in MMR */
#define TWI_IADRSZ_OFFSET			8
#define TWI_IADRSZ_SIZE				2
#define TWI_MREAD_OFFSET			12
#define TWI_MREAD_SIZE				1
#define TWI_DADR_OFFSET				16
#define TWI_DADR_SIZE				7

/* Bitfields in SMR */
#define TWI_SADR_OFFSET				16
#define TWI_SADR_SIZE				7

/* Bitfields in IADR */
#define TWI_IADR_OFFSET				0
#define TWI_IADR_SIZE				24

/* Bitfields in CWGR */
#define TWI_CLDIV_OFFSET			0
#define TWI_CLDIV_SIZE				8
#define TWI_CHDIV_OFFSET			8
#define TWI_CHDIV_SIZE				8
#define TWI_CKDIV_OFFSET			16
#define TWI_CKDIV_SIZE				3

/* Bitfields in SR */
#define TWI_TXCOMP_OFFSET			0
#define TWI_TXCOMP_SIZE				1
#define TWI_RXRDY_OFFSET			1
#define TWI_RXRDY_SIZE				1
#define TWI_TXRDY_OFFSET			2
#define TWI_TXRDY_SIZE				1
#define TWI_SVDIR_OFFSET			3
#define TWI_SVDIR_SIZE				1
#define TWI_SVACC_OFFSET			4
#define TWI_SVACC_SIZE				1
#define TWI_GCACC_OFFSET			5
#define TWI_GCACC_SIZE				1
#define TWI_OVRE_OFFSET				6
#define TWI_OVRE_SIZE				1
#define TWI_UNRE_OFFSET				7
#define TWI_UNRE_SIZE				1
#define TWI_NACK_OFFSET				8
#define TWI_NACK_SIZE				1
#define TWI_ARBLST_OFFSET			9
#define TWI_ARBLST_SIZE				1

/* Bitfields in RHR */
#define TWI_RXDATA_OFFSET			0
#define TWI_RXDATA_SIZE				8

/* Bitfields in THR */
#define TWI_TXDATA_OFFSET			0
#define TWI_TXDATA_SIZE				8

/* Constants for IADRSZ */
#define TWI_IADRSZ_NO_ADDR			0
#define TWI_IADRSZ_ONE_BYTE			1
#define TWI_IADRSZ_TWO_BYTES			2
#define TWI_IADRSZ_THREE_BYTES			3

/* Bit manipulation macros */
#define TWI_BIT(name)					\
	(1 << TWI_##name##_OFFSET)
#define TWI_BF(name, value)				\
	(((value) & ((1 << TWI_##name##_SIZE) - 1))	\
	 << TWI_##name##_OFFSET)
#define TWI_BFEXT(name, value)				\
	(((value) >> TWI_##name##_OFFSET)		\
	 & ((1 << TWI_##name##_SIZE) - 1))
#define TWI_BFINS(name, value, old)			\
	(((old) & ~(((1 << TWI_##name##_SIZE) - 1)	\
		    << TWI_##name##_OFFSET))		\
	 | TWI_BF(name, (value)))

/* Register access macros */
#define twi_readl(port, reg)				\
	__raw_readl((port)->regs + TWI_##reg)
#define twi_writel(port, reg, value)			\
	__raw_writel((value), (port)->regs + TWI_##reg)

#endif /* __ATMELTWI_H__ */
