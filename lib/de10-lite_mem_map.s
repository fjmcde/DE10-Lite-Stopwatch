/*************************************
 ****** DE10-Lite Memory Layout ******
 *************************************/

.equ    MEM_SDRAM_BASE_ADDR,                0x00000000  # base address for the SDRAM
.equ    MEM_FPGA_MEM_BASE_ADDR,             0x08000000  # base address for the on-chip memory
.equ    MEM_FPGA_MEM_CHAR_BUFF_ADDR,        0x09000000  # base address for the on-chip memory character buffer
.equ    MEM_MIMO_BASE_ADDR,                 0xff200000  # base address for the MIMO; for use with the global pointer
.equ    MEM_RED_LEDS_BASE_ADDR,             0xff200000  # base address for the red LEDs
.equ	MEM_SSEG_HEX3_0_BASE_ADDR,	        0xff200020  # base address for the 7-segment hexidecimal displays: Hex3 - Hex0
.equ    MEM_SSEG_HEX5_4_BASE_ADDR,	        0xff200030  # base address for the 7-segment hexidecimal displays: Hex5 - Hex4
.equ    MEM_SLIDER_SWS_BASE_ADDR,           0xff200040  # base address for the slider switches
.equ	MEM_PUSH_BTNS_BASE_ADDR,            0xff200050  # base address for push buttons
.equ    MEM_JP1_EXPAN_BASE_ADDR,            0xff200060  # base address for the JP1 Expansion parallel port
.equ    MEM_ARD_GPIO_BASE_ADDR,             0xff200100  # base address for the Arduino GPIO expansion header parallel port
.equ    MEM_ARD_RESET_N_BASE_ADDR,          0xff200110  # base address for the Arduino Reset
.equ    MEM_JTAG_UART_BASE_ADDR,            0xff201000  # base address for the JTAG UART
.equ    MEM_INT_TIMER1_BASE_ADDR,           0xff202000  # base address for the Interval timer 1
.equ    MEM_INT_TIMER2_BASE_ADDR,           0xff202020  # base address for the Interval timer 2
.equ    MEM_P_BUFFER_CTRL_BASE_ADDR,        0xff203020  # base address for the Video-out port pixel buffer
.equ    MEM_C_BUFFER_CTRL_BASE_ADDR,        0xff203030  # base address for the Video-out port character buffer

