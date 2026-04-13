; ECE 449 - Factorial with Overflow Detection
; Computes OUT = IN! using memory-mapped IO
; If MUL overflows 16-bit signed range, outputs 0 instead
;
; Memory-mapped IO:
;   0xFFF0 = switches (input N)
;   0xFFF2 = LEDs    (output)
;
; Register usage:
;   r0 = input N (counts down to 2)
;   r1 = factorial accumulator
;   r5 = constant 1
;   r6 = constant 2 (loop stop threshold)
;   r7 = scratch / LOADIMM target

START:
        LOADIMM.upper   0x00
        LOADIMM.lower   0x01
        MOV r5, r7              ; r5 = 1

        MOV r1, r5              ; r1 = 1 (factorial accumulator)
        MOV r6, r5              ; r6 = 1
        SHL r6, 1               ; r6 = 2

        LOADIMM.upper   0xFF
        LOADIMM.lower   0xF0
        LOAD r0, r7             ; r0 = M[0xFFF0] = N

LOOP:
        MUL r1, r1, r0          ; r1 = r1 * r0  (sets flag_v on overflow)
        BRR.V OVERFLOW          ; if overflow, jump to error output

        SUB r0, r0, r5          ; r0 = r0 - 1
        SUB r4, r0, r6          ; r4 = r0 - 2
        TEST r4                 ; set N if r4 < 0 (r0 < 2, done)
        BRR.N PRINT             ; done, output result
        BRR LOOP                ; else keep multiplying

PRINT:
        LOADIMM.upper   0xFF
        LOADIMM.lower   0xF2
        STORE r7, r1            ; M[0xFFF2] = r1 -> LEDs
        BRR START

OVERFLOW:
        LOADIMM.upper   0x00
        LOADIMM.lower   0x00    ; r7 = 0
        LOADIMM.upper   0xFF
        LOADIMM.lower   0xF2
        STORE r7, r7            ; M[0xFFF2] = 0 -> LEDs show 0
        BRR START
