/*******************************************
 ****** Symbol Definitions: JTAG UART ******
 *******************************************/


/* ADDRESS */
# JTAG UART: Base Address [ADDR]
.equ JTAG_UART_BASE_ADDR,            0xff201000  # base address for the JTAG UART


/* REGISTER OFFSETS */
# JTAG UART: Register Offsets [REG]
 .equ   UART_DATA_REG_OFFSET,       0   # Byte offset to the DATA register
 .equ   UART_CTRL_REG_OFFSET,       4   # Byte offset to the CONTROL register


/* BIT-FIELDS */
# JTAG UART: Bitfields [DATA]
.equ    UART_DATA_MASK,     0x01        # [7:0]: DATA FIFO; Read: decrements RAVAIL by 1; Write: Loads data into 64-character FIFO
/* Bits 14 - 8 are unused               # [14:8]: UNUSED */
.equ    UART_RVALID_MASK,   0x8000      # [15]: Set when data is present in recieve FIFO
.equ    UART_RAVIL_MASK,    0x10000     # [31:16]: Indicates the number of characters stored in the 64-character FIFO
# JTAG UART: Bitfields [CTRL]
.equ    UART_RE_MASK,       0x01        # [0]: Enable interrupts for recieve FIFO; Generates interrupts when RAVAIL > 7
.equ    UART_WE_MASK,       0x02        # [1]: Enable interrupts for transmit FIFO; Generates interrupts when WSPACE > 7
/* Bits 7 - 2 are unused                # [7:2]: UNUSED */
.equ    UART_RI_MASK,       0x100       # [8]: Asserted when an interrupt is pending from the recieve FIFO; Read from FIFO to deassert
.equ    UART_WI_MASK,       0x200       # [9]: Asserted when an interrupt is pending from the transmit FIFO; Write to FIFO to deassert 
.equ    UART_AC_MASK,       0x400       # [10]: Set when JTAG UART has been accessed by the host
/* Bits 15 - 11 are unused              # [15:11]: UNUSED */
.equ    UART_WSPACE_MASK,   0x10000     # [31:16]: Indicates the amount of space available in the transmit FIFO


/* INTERRUPTS */
# JTAG UART: Interrupts [IRQN]
.equ    UART_IRQn,          0x100       # JTAG UART IRQ#: 8

.end
