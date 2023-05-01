/************************************************
 ****** Symbol Definitions Interval Timers ******
 ************************************************/


/* BASE ADDRESSES */
# Interval Timers: Addresses [ADDR]
.equ    INT_TIMER1_BASE_ADDR,           0xff202000  # base address for the Interval timer 1
.equ    INT_TIMER2_BASE_ADDR,           0xff202020  # base address for the Interval timer 2


/* REGISTER OFFSETS */
# Interval Timer: Register Offsets [REG]
.equ    INT_TIMER_STATUS_OFFSET,        0           # offset for the status register
.equ    INT_TIMER1_CTL_OFFSET,          4           # offset for the Control Register
.equ    INT_TIMER_START_L0W_OFFSET,     8           # offset for the Counter start value low (16-bits) register
.equ    INT_TIMER_START_HIGH_OFFSET,    12          # offset for the Counter start value high (16-bits) register
.equ    INT_TIMER_CNT_LOW_OFFSET,       16          # offset for the Counter snapshot low (16-bits) register
.equ    INT_TIMER_CNT_HIGH_OFFSET,      20          # offset for the Counter snapshot high (16-bits) register

/* BITFIELDS */
# Interval Timers: Bitfields [STATUS]
.equ    INT_TIMER_TO_RESET_MASK,        0x01        # [0]: Write to TO bit will reset it timeout signal
.equ    INT_TIMER_RUN_MASK,             0x02        # [1]: Read-only. Running when set to 1.
/* Bits 15 - 2 are unused (NOTE: 16-BIT REGISTER)   # [15:2]: UNUSED */
# Interval Timers: Bitfields [CONTROL]
.equ    INT_TIMER_ITO_MASK,             0x01        # [0]: Interrupt on timeout
.equ    INT_TIMER_CONT_MASK,            0x02        # [1]: Write to CONT bit for continuous mode
.equ    INT_TIMER_START_MASK,           0x04        # [2]: Write to START bit will start the timer
.equ    INT_TIMER_STOP_MASK,            0x08        # [3]: Write to STOP bit will stop the timer
/* Bits 15 - 4 are unused (NOTE: 16-BIT REGISTER)   # [15:4]: UNUSED */

/* INTERRUPTS */
# Interval Timer: Interrupts [IRQn]
.equ    INT_TIMER1_IRQ,                 0b001        # Interval timer 1 IRQ1: BIT0
.equ    INT_TIMER2_IRQ,                 0b100        # Interval timer 2 IRQ2: BIT2

/* TIMER VALUES */
.equ	TIMER_COUNTER_VAL,		        333332

