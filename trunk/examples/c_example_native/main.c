/*  include files */

#include <stdio.h>
#include <stdlib.h>

#include <sys/cpu.h>
#include <sys/usart.h>

#include "pio.h"
#include "sdram.h"
#include "mt481c2m32b2tg.h"


/* 
 * Dummy functions for the modified crt0.S startup module.
 * We give the option -nostartfiles to the linker to use our own
 * crt0.S. But this option removes also the initialization functions
 * _init() and _fini() (for C++).
 * That's the reason for these two dummy fumctions 
 */
void _init( void ) {}

void _fini( void ) {}

/*!
 * This function will setup the the SDRAM controller and intialize the SDRAM found on the GRASSHOPPER.
 * The function is calle the startup routine in crt0.S.
 * \return None
 */
void  init_sdram_startup( void )
{
  #define SDRAM_BASE 0x10000000
 
  sdram_info *info;
  sdram_info info_s;
  unsigned long sdram_size;
  info = &info_s;

  info->physical_address = SDRAM_BASE | 0xA0000000;
  info->cols = mt481c2m32b2tg_cols;
  info->rows = mt481c2m32b2tg_rows;
  info->banks = mt481c2m32b2tg_banks;
  info->cas = mt481c2m32b2tg_cas;
  info->twr = mt481c2m32b2tg_twr;
  info->trc = mt481c2m32b2tg_trc;
  info->trp = mt481c2m32b2tg_trp;
  info->trcd = mt481c2m32b2tg_trcd;
  info->tras = mt481c2m32b2tg_tras;
  info->txsr = mt481c2m32b2tg_txsr;

  /* Calculate sdram size */
  sdram_size = 1 << (info->rows + info->cols + info->banks + 2);

  // Setup the data bit 16-32
  pio_setup_pin(AVR32_EBI_DATA_16_PIN , AVR32_EBI_DATA_16_FUNCTION);
  pio_setup_pin(AVR32_EBI_DATA_17_PIN , AVR32_EBI_DATA_17_FUNCTION);
  pio_setup_pin(AVR32_EBI_DATA_18_PIN , AVR32_EBI_DATA_18_FUNCTION);
  pio_setup_pin(AVR32_EBI_DATA_19_PIN , AVR32_EBI_DATA_19_FUNCTION);
  pio_setup_pin(AVR32_EBI_DATA_20_PIN , AVR32_EBI_DATA_20_FUNCTION);
  pio_setup_pin(AVR32_EBI_DATA_21_PIN , AVR32_EBI_DATA_21_FUNCTION);
  pio_setup_pin(AVR32_EBI_DATA_22_PIN , AVR32_EBI_DATA_22_FUNCTION);
  pio_setup_pin(AVR32_EBI_DATA_23_PIN , AVR32_EBI_DATA_23_FUNCTION);
  pio_setup_pin(AVR32_EBI_DATA_24_PIN , AVR32_EBI_DATA_24_FUNCTION);
  pio_setup_pin(AVR32_EBI_DATA_25_PIN , AVR32_EBI_DATA_25_FUNCTION);
  pio_setup_pin(AVR32_EBI_DATA_26_PIN , AVR32_EBI_DATA_26_FUNCTION);
  pio_setup_pin(AVR32_EBI_DATA_27_PIN , AVR32_EBI_DATA_27_FUNCTION);
  pio_setup_pin(AVR32_EBI_DATA_28_PIN , AVR32_EBI_DATA_28_FUNCTION);
  pio_setup_pin(AVR32_EBI_DATA_29_PIN , AVR32_EBI_DATA_29_FUNCTION);
  pio_setup_pin(AVR32_EBI_DATA_30_PIN , AVR32_EBI_DATA_30_FUNCTION);
  pio_setup_pin(AVR32_EBI_DATA_31_PIN , AVR32_EBI_DATA_31_FUNCTION);

  /* initialize the avr32 sdram controller */
  sdramc_init(info);

  /* initialize the external sdram chip */
  mt481c2m32b2tg_init(info);
  
  // HJB: stupid ram test
#if 0  
  int n;
  int x;
  int *p;
  
  p = 0x10000000;
  for(n=0; n<1024*1024*16; n++)
    *p++ = n;
  p = 0x10000000;
  x = 0;
    
  for(n=0; n<1024*1024*16; n++)
    if( n != *p++)
      x = 1;  // for breakpoint i case of error
#endif
}

int main( void )
{
  unsigned int n;       // delay counter
  unsigned int cpu_clk; // for test
  unsigned int loops;   // loop counter
  volatile avr32_pio_t *pio = (volatile avr32_pio_t *)AVR32_PIOA_ADDRESS;  // PIO-A handle
	
  extern int __heap_start__,__heap_end__;
  int *p;
  
  //--- Inform the newlib library about the CPU clock   
  set_cpu_hz(20000000);     // my board is clocked with 20MHz after reset
  cpu_clk = get_cpu_hz();  // just for fun
  
//--- setup IO-Lines
  // set pins to the UART0 (rs232 for the terminal)
  pio->pdr = (1<<AVR32_USART0_RXD_0_PIN) | (1<<AVR32_USART0_TXD_0_PIN);
  // UART0 need to select peripheral B
  pio->bsr = (1<<AVR32_USART0_RXD_0_PIN) | (1<<AVR32_USART0_TXD_0_PIN);
  
// Enable output for the pins for the 8 LEDs + PWR LED
  pio->oer = 0x7FC00000;
  
//--- setup UART0 one for stdio (e.g. printf....)
  set_usart_base((void*)AVR32_USART0_ADDRESS);  // init UART driver (set UART0 adress)
  usart_init(115200);                            // init UART0 with 115200 baud
  
//--- We are finish to send the world a message
  printf("\r\nHello World\r\n");  
  printf("heap_start : %p\r\n",&__heap_start__);
  printf("heap_end   : %p\r\n",&__heap_end__);
  printf("\r\nWe now start to alloc the complete SDRAM memory in 1MB steps....\r\n");
  
  for(n=0;n<10000000;n++);  // wasting time for delay
  
  // alloc so many 1MB blocks with malloc as we have SDRAM
  // the result should be 63MB as 1MB is for the stack and so on.
  for(n=0;n<100;n++)
  {
    p = malloc(1024*1024);
    if( p != 0)
      printf("Alloc 1MB, count=%d, addr=%p\r\n",n+1,p);
    else
      break;
  }

  
//--- Main loop  
  loops=0;
  while(1)
  {
    loops++;
    printf("Loop nummer %6d\r\n",loops);
    n = 1000000;
    while(--n);
    pio->codr = 0x40C00000;
    n = 1000000;
    while(--n);
    pio->sodr = 0x40C00000;
  }
  
  /* Should never reach here! */
  return 0;
}
/*-----------------------------------------------------------*/

