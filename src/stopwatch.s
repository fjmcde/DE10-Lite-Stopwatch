.include "../lib/de10-lite_mem_map.s"
.include "../lib/int_timer.s"
.include "../lib/push_buttons.s"
.include "../lib/sseg.s"

.text

.global _start
_start:
    movia   sp, 0x01000000          # setup stack pointer
    movia   gp, MEM_MIMO_BASE_ADDR  # base address for MIMO
	call	reset_gpio				# reset GPIO

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
    subi    sp, sp, 16
	stw     r2, 0(sp)
	stw     r4, 4(sp)
	stw     r5, 8(sp)
	stw     r8, 12(sp)

    # set PIE bit
    movi    r8, 1
    wrctl   status, r8
	
	# initialize push buttons
	call push_btns_init

    # error = intTimerInit(timer_addr, timer_value)
    movia   r4, INT_TIMER1_BASE_ADDR
    movhi   r5, %hi(TIMER_COUNTER_VAL)
    ori		r5,	r5, %lo(TIMER_COUNTER_VAL)
    call intTimerInit

    # error checking
    bne     r2, r0,  program_halt

    # reload caller registers from stack
	ldw     r8, 12(sp)
	ldw     r5, 8(sp)
	ldw     r4, 4(sp)
	ldw     r2, 0(sp)
    addi    sp, sp, 16

# infinite loop
loop:

    br	loop

program_halt:
    # stack epilogue
    ldw     ra, 0(sp)
    addi    sp, sp, 4
    ret


/********************************
 ********** FUNCTIONS ***********
 ********************************/  


.global reset_gpio
reset_gpio:
    # reset seven segment displays
    stwio   r0, 32(gp)
    stwio   r0, 48(gp)
    # reset push buttons
    stwio   r0, 88(gp)
    stwio   r0, 92(gp)
    # reset timer
    stwio   r0, 8200(gp)
    stwio   r0, 8204(gp)
    stwio   r0, 8192(gp)
    stwio   r0, 8196(gp)
    ret



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
    subi    sp, sp, 12
	stw		ra, 0(sp)
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
	rdctl	r17, ienable
	or		r16, r16, r17
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
	
    # set stop bit (timer initializes to STOP state)
	movia	r16, 0xff202004
	movi	r17, 0b1000
	stwio   r17, 0(r16)
end_init:
	call    encode_sseg

    # stack epilogue
    ldw     r17, 8(sp)
    ldw     r16, 4(sp)
	ldw		ra, 0(sp)
    addi    sp, sp, 12

    ret


.global push_btns_init
push_btns_init:
	# stack prologue
	subi	sp, sp, 8
	stw		r16, 0(sp)
	stw		r17, 4(sp)
	
	# enable push button interrupts
    movi    r17, PUSH_BTN_IRQn
	
	rdctl	r16, ienable
	or		r16, r16, r17
    wrctl   ienable,  r16
	
	# set bits in Interrupt Mask register
	movi	r17, 0b11
	movia	r16, PUSH_BTNS_BASE_ADDR
	stwio	r17, 8(r16)
	
	# stack epilogue
	ldw		r17, 4(sp)
	ldw		r16, 0(sp)
	addi	sp, sp, 8
	ret

.global timer_counter
timer_counter:
    # count++, store on stack
    ldw     r8, count(r0)
    addi    r8, r8, 1
    stw     r8, count(r0)

	# stack prologue
	subi    sp, sp, 28
	stw		ra, 0(sp)
    stw     r2, 4(sp)
    stw     r4, 8(sp)
    stw     r5, 12(sp)
    stw     r8, 16(sp)
    stw     r9, 20(sp)
    stw     r10, 24(sp)
hex_0:
    # hex_count[0] = a_mod_n(count, 10)
    ldw     r4, 16(sp)
    ldw     r5, mod_array(r0)
    call    a_mod_n 
    stw     r2, hex_count(r0)

    #if(count % 10 == 0)
    bne     r2, r0, end
hex_1:
	# byte index for HEX1
    movi    r9, 4

    # if(count % 100 == 0) { hex_count[4] = 0 }
    ldw     r4, 16(sp)
    ldw     r5, mod_array(r9)
    call    a_mod_n
    bne     r2, r0, increment_hex1
    stw     r0, hex_count(r9)
	br		hex_2
increment_hex1:
	# hex_count[4]++ 
	ldw     r10, hex_count(r9)
	addi    r10, r10, 1
	stw     r10, hex_count(r9)
	br		end
hex_2:
	# byte index for HEX2
    movi    r9, 8

    # if(count % 1000 == 0) { hex_count[8] = 0 }
    ldw     r4, 16(sp)
    ldw     r5, mod_array(r9)
    call    a_mod_n
    bne     r2, r0, increment_hex2
	movi	r10, 10
    stw     r10, hex_count(r9)
	br		hex_3
increment_hex2:
	# hex_count[8]++ 
	ldw     r10, hex_count(r9)
	addi    r10, r10, 1
	stw     r10, hex_count(r9)
	br		end
hex_3:
	# byte index for HEX3
    movi    r9, 12

    # if(count % 6000 == 0) { hex_count[12] = 0 }
    ldw     r4, 16(sp)
    ldw     r5, mod_array(r9)
    call    a_mod_n
    bne     r2, r0, increment_hex3
    stw     r0, hex_count(r9)
	br		hex_4
increment_hex3:
	# hex_count[12]++ 
	ldw     r10, hex_count(r9)
	addi    r10, r10, 1
	stw     r10, hex_count(r9)
	br		end
hex_4:
	# byte index for HEX4
    movi    r9, 16

    # if(count % 60000 == 0) { hex_count[16] = 0 }
    ldw     r4, 16(sp)
    ldw     r5, mod_array(r9)
    call    a_mod_n
    bne     r2, r0, increment_hex4
	movi	r10, 10
    stw     r10, hex_count(r9)
	br		hex_5
increment_hex4:
	# hex_count[16]++ 
	ldw     r10, hex_count(r9)
	addi    r10, r10, 1
	stw     r10, hex_count(r9)
	br		end
hex_5:
	# byte index for HEX5
    movi    r9, 20

    # if(count % 600000 == 0) { hex_count[20] = 0 }
    ldw     r4, 16(sp)
    ldw     r5, mod_array(r9)
    call    a_mod_n
    bne     r2, r0, increment_hex5
    stw     r0, hex_count(r9)
	br		end
increment_hex5:
	# hex_count[12]++ 
	ldw     r10, hex_count(r9)
	addi    r10, r10, 1
	stw     r10, hex_count(r9)
	br		end
end:
	call encode_sseg

    # store on stack
    ldw     r10, 24(sp)
    ldw     r9, 20(sp)
    ldw     r8, 16(sp)
    ldw     r5, 12(sp) 
    ldw     r4, 8(sp) 
    ldw     r2, 4(sp)
	ldw		ra, 0(sp)
    addi    sp, sp, 28

    ret
	
	
	
.global a_mod_n
a_mod_n:
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
	

#	r4 = hex_count[]
.global convert_byte
convert_byte:
    # stack prologue
	subi	sp, sp, 4
	stw		r16, 0(sp)

	muli	r16, r4, 4
	ldw		r16, encoded_count(r16)

    mov     r2, r16

    # stack epilogue
	ldw		r16, 0(sp)
    addi	sp, sp, 4
	
	ret	
	
.global encode_sseg
encode_sseg:
    # stack prologue
    subi    sp, sp, 24
    stw     ra, 0(sp)
	stw		r2, 4(sp)
	stw		r4, 8(sp)
    stw     r16, 12(sp)
	stw		r17, 16(sp)
	stw		r18, 20(sp)

	# byte indexing: i = 20
	movi	r18, 20

    # build seven segment packet 1
	# converted_bytes = convert_byte(hex_count[20]) << 8
	ldw		r4, hex_count(r18)
	call	convert_byte
	slli	r16, r2, 8

	subi	r18, r18, 4

	# converted_bytes |= convert_byte(hex_count[16])
	ldw		r4, hex_count(r18)
	call	convert_byte
	or		r16, r16, r2

	# encode packet to HEX5 - HEX4
	movia   r17, SSEG_HEX5_4_BASE_ADDR
    stwio   r16, 0(r17)

	subi	r18, r18, 4

    # build seven segment packet 2
	# converted_bytes = convert_byte(hex_count[12]) << 8
	ldw		r4, hex_count(r18)
	call	convert_byte
	slli	r16, r2, 8

	subi	r18, r18, 4

	# converted_bytes |= convert_byte(hex_count[8])
	ldw		r4, hex_count(r18)
	call 	convert_byte
	or		r16, r16, r2

	# converted_bytes <<= 16
	slli	r16, r16, 16

	subi	r18, r18, 4

	# converted_bytes |= convert_byte(hex_count[4]) << 8
	ldw		r4, hex_count(r18)
	call	convert_byte
	slli	r17, r2, 8
	or		r16, r16, r17

	# converted_bytes |= convert_byte(hex_count[0])
	ldw		r4, hex_count(r0)
	call	convert_byte
	or		r16, r16, r2
	
	# encode packet to HEX3 - HEX0
	movia   r17, SSEG_HEX3_0_BASE_ADDR
    stwio   r16, 0(r17)

    # stack epilogue
	ldw		r18, 20(sp)
	ldw		r17, 16(sp)
	ldw     r16, 12(sp)
	ldw		r4, 8(sp)
	ldw     r2, 4(sp)
    ldw     ra, 0(sp)
    addi    sp, sp, 24

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
    # adjust exception address and read ipending register
    subi    ea, ea, 4
	rdctl   et, ipending

    # stack prologue
    subi     sp, sp, 12
    stw     ra, 0(sp)
	stw		et,	4(sp)	# not necessary, but conviently located
    stw     r8, 8(sp)

    # Determine either external or interal IRQ
    bne     et, r0, ISR_External

    # internal exceptions are not handled
    br      END_ISR

ISR_External:
Timer_ISR:
    # check for timer1 IRQ: #0
    andi    r8, et, INT_TIMER1_IRQ
    beq     r8, r0, PUSH_BTN_ISR
    movia   et, INT_TIMER1_BASE_ADDR

LOWER_TIMER_IF:
    # write any value to timer status register to
    # deassert TO bit; lowing the IF
    movi    r8, 1
    stwio   r8, 0(et) 

    call    timer_counter

    br      END_ISR
PUSH_BTN_ISR:
	# store edge capture register state on stack
	movia   r8, PUSH_BTNS_BASE_ADDR
	ldwio	r8, 12(r8)
	subi	sp, sp, 4
	stw		r8, 0(sp)

	# check for push button IRQ: #1
	andi    r8, et, PUSH_BTN_IRQn
    beq     r8, r0, END_ISR
LOWER_BTN_IF:
    # write to push button edge capture 
	# register to lower interrupt flag(s)
    movia   r8, PUSH_BTNS_BASE_ADDR
	ldwio	et, 12(r8)
    stwio   et, 12(r8)
BTN_SM:
	# RUN_bit = status_reg << 1
	movia	r8, INT_TIMER1_BASE_ADDR
	ldwio	et, 0(r8)
	srli	et, et, 1
	
	#if(RUNNING)
	bne		et, r0, RUNNING
STOPPED:
	# if(Start/Stop)
	ldw		r8, 0(sp)
	movi	et,	0b01
	bne		r8, et,  STOP_BTN1_PRESSED
STOP_BTN0_PRESSED:
	# timer_ctrl |= (START + CONT)
	movia	r8, INT_TIMER1_BASE_ADDR
	movi	et, 0b111
	stwio	et, 4(r8)
	br		END_BTN_ISR
STOP_BTN1_PRESSED:
	# Lap/Reset pressed
	# reset
	call reset_gpio
	br	END_BTN_ISR
RUNNING:
	# if(Start/Stop)
	ldw		r8, 0(sp)
	movi	et,	0b01
	bne		r8, et, RUNNING_BTN1_PRESSED
RUNNING_BTN0_PRESSED:
	# timer_ctrl = STOP
	movia	r8, INT_TIMER1_BASE_ADDR
	movi	et, 0b1000
	stwio	et, 4(r8)
	
	# clear TO bit
	movi	et, 0b01
	stwio	et, 0(r8)
	br		END_BTN_ISR
RUNNING_BTN1_PRESSED:
	# Lap/Reset pressed
	# clear ITO bit
	movia	r8, INT_TIMER1_BASE_ADDR
	movi	et, 0b1110
	stwio	et, 4(r8)
	br		END_BTN_ISR
END_BTN_ISR:
	addi	sp, sp, 4
END_ISR:
    # stack epilogue
    ldw     r8, 8(sp)
	ldw		et, 4(sp)
    ldw     ra, 0(sp)
    addi    sp, sp, 12

    eret

.section .data
hexn:
    .word   0x3F, 0x3F, 0xBF, 0x3F, 0xBF, 0x3F
hex_count:
	.word	0, 0, 10, 0, 10, 0
encoded_count:
	.word	0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x67
	.word 	0xBF, 0x86, 0xDB, 0xCF, 0xE6, 0xED, 0xFD, 0x87, 0xFF, 0xE7
mod_array:
	.word	10, 100, 1000, 6000, 60000, 600000
count:
	.word	0
.end