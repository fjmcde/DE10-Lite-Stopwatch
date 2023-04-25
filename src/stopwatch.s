.include "../lib/de10-lite_mem_map.s"
.include "../lib/int_timer.s"
.include "../lib/push_buttons.s"
.include "../lib/sseg.s"

.text

.global _start
_start:
    movia   sp, 0x01000000          # setup stack pointer
    movia   gp, MEM_MIMO_BASE_ADDR  # base address for MIMO
    

    # main should not return; halt if it does
    call main
    break


/***************************************
 ********** APPLICATION CODE ***********
 ***************************************/  


/*************************************//**
 * main() - Stopwatch main function
 *
 * param: NONE
 * return: NONE
 ****************************************/
.global main
main:
    # stack prologue
    subi    sp, sp, 4
    stw     ra, 0(sp)


    # set PIE bit
    movi    r8, 1
    wrctl   status, r8

    # store caller registers on stack
    subi    sp, sp, 4
    stw     r8, 0(sp)

    # set function arguements
    movia   r4, INT_TIMER1_BASE_ADDR
    movhi   r5, %hi(1000000000)
    ori		r5,	r5, %lo(1000000000)
    call intTimerInit

    # reload caller registers from stack
    ldw     r8, 0(sp)
    addi    sp, sp, 4

    # error checking
    bne     r2, r0,  program_halt

top_of_loop:

    br top_of_loop

program_halt:
    # stack epilogue
    ldw     ra, 0(sp)
    addi    sp, sp, 4
    ret


/********************************
 ********** FUNCTIONS ***********
 ********************************/  


/*************************************************************
 * Interval Timer Init(timer_addr, start_val)
 *
 * param: r4 - timer_addr
 *      Base address for either interval 
 *      Timer1 or interval Timer2
 * param: r5 - start_value
 *      desired start value
 *
 *  Registers Used:
 *      r16: for loading/storing of peripheral registers
 *      r17: for intermediate storage or values
 *
 * return: r2 - validTimer
 *       Returns 0 for a valid timer address
 *       Returns -1 for an invalid timer address
 ************************************************************/
 .global intTimerInit
intTimerInit:
    # stack prologue
    subi    sp, sp, 12
    stw     ra, 0(sp)
    stw     r16, 4(sp)
    stw     r17, 8(sp)

    # check if Timer1 is being used
    movia   r16, INT_TIMER1_BASE_ADDR
    beq     r4, r16, timer1
    # ... else: check if Timer2 is being used
    movia   r16, INT_TIMER2_BASE_ADDR
    beq     r4, r16, timer2
    # ... else: invalid address
    movi    r2, -1
    br      end_init

timer1:
    #load timer1 IRQ
    movi    r16, INT_TIMER1_IRQ
    br  valid_addr

timer2:
    # load Timer2 IRQ
    movi    r16, INT_TIMER2_IRQ

valid_addr:
    # valid address: set return value
    mov    r2, r0  

    # enable timer interrupt
    wrctl   ienable,  r16

    # load status register from interval timer
    ldwio   r16, 0(r4)
    srli    r16, r16, 1

    # check if timer is already running... 
    bne     r16, r0, end_init

timer_not_running:
    # set counter start value (low)
	movia	r16, 0xff202008
	slli	r17, r5, 16
	srli	r17, r17, 16
	stwio	r17, 0(r16)
    
    # set counter start value (high)
	movia	r16, 0xff20200c
	srli	r17, r5, 16
	stwio	r17, 0(r16)
	
    # set START, CONT, and ITO bits (0b111)
	movia	r16, 0xff202004
	movi	r17, 0x07
	stwio   r17, 0(r16)

end_init:
    # stack epilogue
    ldw     r17, 8(sp)
    ldw     r16, 4(sp)
    ldw     ra, 0(sp)
    addi    sp, sp, 12

    ret


.global encode_sseg
encode_sseg:

	ret


/**************************************************
 ***************** SECTION: RESET *****************
 **************************************************/   

.section .reset,    "ax"    # Reset vector 0x00000000
    movia   r2, _start  
    jmp		r2              # Branch to main



/**************************************************
 ********** SECTION: EXCEPTION HANDLERS ***********
 **************************************************/  

.section .exceptions,   "ax"    # Exception Vector 0x00000020
EXCEPTION_HANDLER:
    # Determine either external or interal IRQ
    rdctl   et, ipending            
    bne     et, r0, ISR_External

    # internal exceptions are not handled
    eret

ISR_External:
    # adjust exception address
    subi    ea, ea, 4

    # stack prologue
    subi    sp, sp, 8
    stw     ea, 0(sp)
    stw     r8, 4(sp)

Timer1_ISR:
    # check if Interval Timer1 IRQ
    andi    r8, et, INT_TIMER1_IRQ
    beq     r8, r0, Timer2_ISR

    # store return address on stack
    subi    sp, sp, 4
    stw     ra, 0(sp)

    call    encode_sseg

    # load ra from stack
    ldw     ra, 0(sp)
    addi    sp, sp, 4

    br      END_ISR


Timer2_ISR:
    andi    r8, et, INT_TIMER2_IRQ
    beq     r8, r0, END_ISR

    # store return address on stack
    subi    sp, sp, 4
    stw     ra, 0(sp)

    call    encode_sseg

    # load ra from stack
    ldw     ra, 0(sp)
    addi    sp, sp, 4

    br      END_ISR

END_ISR:
    ldw     r8, 4(sp)
    ldw     ea, 0(sp)
    addi    sp, sp, 8

    eret

.end
