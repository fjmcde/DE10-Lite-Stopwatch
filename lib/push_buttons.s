/**********************************************
 ****** Symbol Definitions: Push Buttons ******
 **********************************************/

/* BASE ADDRESS */
# Push Buttons: Address [ADDR]
.equ	PUSH_BTNS_BASE_ADDR,            0xff200050  # base address for push buttons


/* REGISTER OFFSETS */
# Push Buttons: Register Offsets [REG]
.equ	PUSH_BTNS_DATA_TEG_OFFSET,          0       # byte offset for the Interrupt Mask Register 
/* Unused register at byte offset 4                 # UNUSED */
.equ	PUSH_BTNS_INT_MASK_REG_OFFSET,      8       # byte offset for the Interrupt Mask Register
.equ	PUSH_BTNS_EDGE_CAP_REG_OFFSET,      12      # byte offset for the Edge Capture Register


/* BIT-FIELDS */
# Push Buttons: Bitfields [DATA]
.equ	PUSH_BTN0_DATA_MASK,        0x01    # [0]: High indicates BUTTON0 has been pressed. READ-ONLY.
.equ	PUSH_BTN1_DATA_MASK,        0x02    # [1]: High indicates BUTTON1 has been pressed, READ-ONLY.
/* Bits 31 - 2 are unused                   # [31:2]: UNUSED */
# Push Buttons: Bitfields [INT MASK]
.equ	PUSH_BTN0_INT_MASK,         0x01    # [0]: Set to enable interrupts on BUTTON0
.equ	PUSH_BTN1_INT_MASK,         0x02    # [1]: Set to enable interrupts on BUTTON1
/* Bits 31 - 2 are unused                   # [31:2]: UNUSED */
# Push Buttons: Bitfields [EDGE CAP]
.equ	PUSH_BTN0_EDGE_CAP_MASK,    0x01    # [0]: Asserted when BUTTON0 generates an interrupt; Write to deassert ALL bits in field
.equ	PUSH_BTN1_EDGE_CAP_MASK,    0x02    # [1]: Asserted when BUTTON1 generates an interrupt; Write to deasset ALL bits in field
/* Bits 31 - 2 are unused                   # [31:2]: UNUSED */


/* INTERRUPTS */
# Push Buttons: IRQ
.equ    PUSH_BTN_IRQn,          0x10        # Push button IRQ#: 1

