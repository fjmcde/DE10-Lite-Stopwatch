/***********************************************
 ****** Symbol Definitions for Characters ******
 ***********************************************/


/* BASE ADDRESSES */
# Seven-Segment Display: Addresses [ADDR]
.equ	SSEG_HEX3_0_BASE_ADDR,	0xff200020  # base address for hex displays: Hex3 - Hex0
.equ    SSEG_HEX5_4_BASE_ADDR,  0xff200030  # base address for hex displays: Hex5 - Hex4


/* NUMBERS */
# Seven-Segment Display: Numbers [NUMn]
.equ	SSEG_NUM0,  0x3F    # Output 0 to seven segment display
.equ	SSEG_NUM1,  0x06    # Output 1 to seven segment display
.equ	SSEG_NUM2,  0x5B    # Output 2 to seven segment display
.equ	SSEG_NUM3,  0x4F    # Output 3 to seven segment display
.equ	SSEG_NUM4,  0x66    # Output 4 to seven segment display
.equ	SSEG_NUM5,  0x6c    # Output 5 to seven segment display
.equ	SSEG_NUM6,  0x7D    # Output 6 to seven segment display
.equ	SSEG_NUM7,  0x07    # Output 7 to seven segment display
.equ	SSEG_NUM8,  0x7F    # Output 8 to seven segment display
.equ	SSEG_NUM9,  0x67    # Output 9 to seven segment display

/* LETTERS */
# Seven-Segment Display: Letters [CHARx]

