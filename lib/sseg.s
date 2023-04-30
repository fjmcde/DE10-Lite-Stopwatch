/***********************************************
 ****** Symbol Definitions for Characters ******
 ***********************************************/


/* BASE ADDRESSES */
# Seven-Segment Display: Addresses [ADDR]
.equ	SSEG_HEX3_0_BASE_ADDR,	0xff200020  # base address for hex displays: Hex3 - Hex0
.equ    SSEG_HEX5_4_BASE_ADDR,  0xff200030  # base address for hex displays: Hex5 - Hex4


/* NUMBERS */
# Seven-Segment Display: Numbers [ENCODEn]
.equ	SSEG_ENCODE0,       0x3F    # Output 0 to seven segment display
.equ	SSEG_ENCODE1,       0x06    # Output 1 to seven segment display
.equ	SSEG_ENCODE2,       0x5B    # Output 2 to seven segment display
.equ	SSEG_ENCODE3,       0x4F    # Output 3 to seven segment display
.equ	SSEG_ENCODE4,       0x66    # Output 4 to seven segment display
.equ	SSEG_ENCODE5,       0x6c    # Output 5 to seven segment display
.equ	SSEG_ENCODE6,       0x7D    # Output 6 to seven segment display
.equ	SSEG_ENCODE7,       0x07    # Output 7 to seven segment display
.equ	SSEG_ENCODE8,       0x7F    # Output 8 to seven segment display
.equ	SSEG_ENCODE9,       0x67    # Output 9 to seven segment display
.equ	SSEG_ENCODE0_,      0xBF    # Output 0. to seven segment display
.equ	SSEG_ENCODE1_,      0x86    # Output 1. to seven segment display
.equ	SSEG_ENCODE2_,      0xDB    # Output 2. to seven segment display
.equ	SSEG_ENCODE3_,      0xCF    # Output 3. to seven segment display
.equ	SSEG_ENCODE4_,      0xE6    # Output 4. to seven segment display
.equ	SSEG_ENCODE5_,      0xEc    # Output 5. to seven segment display
.equ	SSEG_ENCODE6_,      0xFD    # Output 6. to seven segment display
.equ	SSEG_ENCODE7_,      0x87    # Output 7. to seven segment display
.equ	SSEG_ENCODE8_,      0xFF    # Output 8. to seven segment display
.equ	SSEG_ENCODE9_,      0xE7    # Output 9. to seven segment display
.equ    SSEG_ENCODE_OFF,    0x00    # Turn seven segment display OFF

/* OFFSETS */
# Bitfield offsets [HEXn]
.equ    SSEG_HEX5,          1
.equ    SSEG_HEX2,          0
.equ    SSEG_HEX3,          3
.equ    SSEG_HEX2,          2
.equ    SSEG_HEX1,          1
.equ    SSEG_HEX0,          0

/* BITMASKS */
# Display masks
.equ    SSEG_5_4_DEFAULT,    0x3FBF      # 00.xx_xx
.equ    SSEG_3_0_DEFAULT,    0x3FBF3F3F  # xx_00.00