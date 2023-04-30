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
    movhi   r5, %hi(100000)
    ori		r5,	r5, %lo(100000)
    call intTimerInit

    # error checking
    bne     r2, r0,  program_halt

    # initialize seven segment displays
    call    init_sseg

    # reload caller registers from stack
    ldw     r8, 0(sp)
    addi    sp, sp, 4

# infinite loop
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
 * intTimerInit(timer_addr, start_val)
 *
 * Details:
 * Initializes, starts, and enables interrupts for 
 * desired interval timer
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
 * return: r2 - error_code
 *       Returns 0 for a valid timer address
 *       Returns -1 for an invalid timer address
 ************************************************************/
 .global intTimerInit
intTimerInit:
    # stack prologue
    subi    sp, sp, 8
    stw     r16, 0(sp)
    stw     r17, 4(sp)

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
    ldw     r17, 4(sp)
    ldw     r16, 0(sp)
    addi    sp, sp, 8

    ret


/*************************************************************
 * init_sseg(void)
 * 
 * Details:
 *      Initialized the seven segment displays to the
 *      default 00.00.00
 *
 * param: NONE
 *
 * Registers Used:
 *      r16: for loading/storing of peripheral registers
 *      r17: for intermediate storage or values

 * return: NONE
 ************************************************************/
.global init_sseg
init_sseg:
    # stack prologue
    subi    sp, sp, 8
    stw     r16, 0(sp)
    stw     r17, 4(sp)

    # store default value for HEX3 - HEX0
    movia   r16, SSEG_HEX3_0_BASE_ADDR
    movhi   r17, %hi(SSEG_3_0_DEFAULT)
    ori     r17, r17, %lo(SSEG_3_0_DEFAULT)   
    stwio   r17, 0(r16)
    
    # store default value for HEX5 - HEX4
    movia   r16, SSEG_HEX5_4_BASE_ADDR
    movhi   r17, %hi(SSEG_5_4_DEFAULT)
    ori     r17, r17, %lo(SSEG_5_4_DEFAULT)   
    stwio   r17, 0(r16)

    # stack epilogue
    ldw     r17, 4(sp)
    ldw     r16, 0(sp)
    addi    sp, sp, 8
    ret


/*************************************************************
 * mod(a, n)
 * 
 * Details:
 *      Modulo operation
 *
 * param:
 *      r4 - a
 *          dividend term
 *      r5 - n
 *          divisor term 
 *
 * Registers Used:
 *      r16: q - stores the quotient of div
 *      r17: p - stores the product of mul
 *
 * return:
 *      r2 - r
 *          returns the remainder of (a % n)
 ************************************************************/
.global mod
mod:
    # stack prologue
    subi    sp, sp, 8
    stw     r16, 0(sp)
    stw     r17, 4(sp)

    # r = a mod n
	div		r16, r4, r5	    # q = a / n
	mul		r17, r16, r5	# p = q * n
	sub		r2, r4, r17	    # r = a - p


    # stack epilogue
    ldw     r17, 4(sp)
    ldw     r16, 0(sp)
    addi    sp, sp, 8

    ret   


/*************************************************************
 * update_sseg_vals(void)
 * 
 * Details:
 *      updates the values to be output to the 
 *      seven segment displays. 
 *      
 *      NOTE: does not output the values use the
 *      return values as arguements for encode_sseg() 
 *      function
 *
 * param: NONE
 *
 * Registers Used:
 *      r2: to hold return word from mod function
 *      r4: to hold function arguement for mod function
 *      r5: to hold function arguement for mod function
 *      r16: for loading/storing of peripheral registers
 *
 * return: 
 *      r2: value to encode to HEX3 - HEX0
 *      r3: value to encode to HEX5 - HEX4
 ************************************************************/
.global update_sseg_vals
update_sseg_vals:
    # stack prologue
    subi    sp, sp, 8
    stw     ra, 0(sp)
    stw     r16, 4(sp)


    # hundredths place (ms)
h_ms:
	# load & increment dividend term
	ldw		r4, hundredths_ms(r0)
	addi	r4, r4, 1

    # load divisor term
    movi    r5, 10

    # r2 = hundredths_ms % 10
    call    mod

    # store new value
    stw     r4, hundredths_ms(r0)

    # if(r2 == 0){}
    bne     r2, r0, end_tick
    
    # reset hundredths place (ms) to 0
    ldw     r4, hundredths_ms(r0)
    movi    r4, 0
    stw     r4, hundredths_ms(r0)

# tenths place (ms)
t_ms:
    # load & increment dividend term 
    ldw     r4, tenths_ms(r0)
    addi    r4, r4, 1

    # load divisor term
    movi    r5, 10

    # r2 = tenths_ms % 10
    call    mod

    # store new value
    stw     r4, tenths_ms(r0)

    #if(r2 == 0)
    bne     r2, r0, end_tick

    # reset tenths place (ms) to 0
    ldw     r4, tenths_ms(r0)
    movi    r4, 0
    stw     r4, tenths_ms(r0)

# ones place (s)
o_s:
    # load & increment dividend term 
    ldw     r4, ones_sec(r0)
    addi    r4, r4, 1

    # load divisor term
    movi    r5, 10

    # r2 = ones_sec % 10
    call    mod

    # store new value
    stw     r4, ones_sec(r0)

    #if(r2 == 0)
    bne     r2, r0, end_tick

    # reset ones place (s) to 0
    ldw     r4, ones_sec(r0)
    movi    r4, 0
    stw     r4, ones_sec(r0)

# tens place (s)
t_s:
    # load & increment dividend term 
    ldw     r4, tens_sec(r0)
    addi    r4, r4, 1

    # load divisor term
    movi    r5, 6

    # r2 = tens_sec % 6
    call    mod

    # store new value
    stw     r4, tens_sec(r0)

    #if(r2 == 0)
    bne     r2, r0, end_tick

    # reset tens place (s) to 0
    ldw     r4, tens_sec(r0)
    movi    r4, 0
    stw     r4, tens_sec(r0)

# ones place (min)
o_m:
    # load & increment dividend term 
    ldw     r4, ones_min(r0)
    addi    r4, r4, 1

    # load divisor term
    movi    r5, 10

    # r2 = ones_min % 10
    call    mod

    # store new value
    stw     r4, ones_min(r0)

    #if(r2 == 0)
    bne     r2, r0, end_tick

    # reset ones place (min) to 0
    ldw     r4, ones_min(r0)
    movi    r4, 0
    stw     r4, ones_min(r0)

# tens place (min)
t_m:
    # load & increment dividend term 
    ldw     r4, tens_min(r0)
    addi    r4, r4, 1

    # load divisor term
    movi    r5, 10

    # r2 = tens_min % 10
    call    mod

    # store new value
    stw     r4, tens_min(r0)

    #if(r2 == 0)
    bne     r2, r0, end_tick

    # reset ones place (min) to 0
    ldw     r4, tens_min(r0)
    movi    r4, 0
    stw     r4, tens_min(r0)

end_tick:
# Store bytes for HEX3 - HEX0
# high half word
    # MSByte
    ldw     r16, tens_sec(r0)
    slli    r2, r16, 8
    # LSByte
    ldw     r16, ones_sec(r0) 
    addi    r16, r16, 10             # add ten to encode with decimal point
    or      r2, r2, r16
    slli    r2, r2, 16

# low half word
    # MSByte
    ldw     r16, tenths_ms(r0)
    slli    r16, r16, 8
    or      r2, r2, r16
    # LSByte
    ldw     r16, hundredths_ms(r0)
    or      r2, r2, r16

# store bytes for HEX5 - HEX4
    # MSByte
    ldw     r16, tens_min(r0)
    slli    r3, r16, 8
    #LSByte
    ldw     r16, ones_min(r0)
    addi    r16, r16, 10             # add ten to encode with decimal point
    or      r3, r3, r16
    
    # stack epilogue
    ldw     r16, 4(sp)
    ldw     ra, 0(sp)
    addi    sp, sp, 8

    ret


/*************************************************************
 * encode_sseg(encode_value1, encode_value2)
 * 
 * Details:
 *      Encodes timer value and outputs to the seven segment
 *      displays.
 *
 * param: r4 - encode_value1
 *      Value to encode to HEX3 - HEX0
 * param: r5 - encode_value2
 *      Value to encode to HEX5 - HEX4
 *
 * Registers Used:
 *      r16: for loading/storing of peripheral registers
 *      r17: for intermediate storage or values
 *
 * return: NONE
 ************************************************************/
.global encode_sseg
encode_sseg:
    # stack prologue
    subi    sp, sp, 8
    stw     r16, 0(sp)
    stw     r17, 4(sp)

	# encode value to HEX3 - HEX0
    movia   r16, SSEG_HEX3_0_BASE_ADDR
    stwio   r4, 0(r16)

    # encode value to HEX5 - HEX4
    movia   r16, SSEG_HEX5_4_BASE_ADDR
    stwio   r5, 0(r16)


    # stack epilogue
    ldw     r17, 4(sp)
    ldw     r16, 0(sp)
    addi    sp, sp, 8

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

Timer_ISR:
    # check for timer1 IRQ: #1
    andi    r8, et, INT_TIMER1_IRQ
    beq     r8, r0, Timer2

Timer1:
    # fetch timer1 status register
    movia   et, INT_TIMER1_BASE_ADDR
    br      lower_timer_IF

Timer2:
    # check for timer2 IRQ: #3
    andi    r8, et, INT_TIMER2_IRQ
    beq     r8, r0, END_ISR

    # fetch timer2 status register
    movia   et, INT_TIMER2_BASE_ADDR

lower_timer_IF:
    # write any value to timer status register to
    # deasset TO bit; lowing the IF
    movi    r8, 1
    stwio   r8, 0(et)

    # store ABI compliant registers on stack
    subi    sp, sp, 20
    stw     ra, 0(sp)
    stw     r2, 4(sp)
    stw     r3, 8(sp)
    stw     r4, 12(sp)
    stw     r5, 16(sp)

    # update seven segment display values
    call    update_sseg_vals

    # r4, r5 = update_sseg_vals()
    mov     r4, r2
    mov     r5, r3

    # encode and output updated sseg values
    call    encode_sseg

    # load ABI compliant registers from stack
    ldw     r5, 16(sp)
    ldw     r4, 12(sp)
    ldw     r3, 8(sp)
    ldw     r2, 4(sp)
    ldw     ra, 0(sp)
    addi    sp, sp, 20

    br      END_ISR

END_ISR:
    ldw     r8, 4(sp)
    ldw     ea, 0(sp)
    addi    sp, sp, 8

    eret

.section .data
# millseconds
hundredths_ms:      .word   0
tenths_ms:          .word   0
# seconds:
ones_sec:           .word   0
tens_sec:           .word   0
# minutes
ones_min:           .word   0
tens_min:           .word   0
.end