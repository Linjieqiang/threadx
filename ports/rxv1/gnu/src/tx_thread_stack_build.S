;/**************************************************************************/
;/*                                                                        */
;/*       Copyright (c) Microsoft Corporation. All rights reserved.        */
;/*                                                                        */
;/*       This software is licensed under the Microsoft Software License   */
;/*       Terms for Microsoft Azure RTOS. Full text of the license can be  */
;/*       found in the LICENSE file at https://aka.ms/AzureRTOS_EULA       */
;/*       and in the root directory of this software.                      */
;/*                                                                        */
;/**************************************************************************/
;
;
;/**************************************************************************/
;/**************************************************************************/
;/**                                                                       */
;/** ThreadX Component                                                     */
;/**                                                                       */
;/**   Thread                                                              */
;/**                                                                       */
;/**************************************************************************/
;/**************************************************************************/

    .text
;/**************************************************************************/
;/*                                                                        */
;/*  FUNCTION                                               RELEASE        */
;/*                                                                        */
;/*    _tx_thread_stack_build                               RXv1/GNURX     */
;/*                                                           6.1.9        */
;/*  AUTHOR                                                                */
;/*                                                                        */
;/*    William E. Lamie, Microsoft Corporation                             */
;/*                                                                        */
;/*  DESCRIPTION                                                           */
;/*                                                                        */
;/*    This function builds a stack frame on the supplied thread's stack.  */
;/*    The stack frame results in a fake interrupt return to the supplied  */
;/*    function pointer.                                                   */
;/*                                                                        */
;/*  INPUT                                                                 */
;/*                                                                        */
;/*    thread_ptr                            Pointer to thread control blk */
;/*    function_ptr                          Pointer to return function    */
;/*                                                                        */
;/*  OUTPUT                                                                */
;/*                                                                        */
;/*    None                                                                */
;/*                                                                        */
;/*  CALLS                                                                 */
;/*                                                                        */
;/*    None                                                                */
;/*                                                                        */
;/*  CALLED BY                                                             */
;/*                                                                        */
;/*    _tx_thread_create                     Create thread service         */
;/*                                                                        */
;/*  RELEASE HISTORY                                                       */
;/*                                                                        */
;/*    DATE              NAME                      DESCRIPTION             */
;/*                                                                        */
;/*  08-02-2021     William E. Lamie         Initial Version 6.1.8         */
;/*  10-15-2021     William E. Lamie         Modified comment(s), and      */
;/*                                            removed unnecessary stack   */
;/*                                            type placement,             */
;/*                                            resulting in version 6.1.9  */
;/*                                                                        */
;/**************************************************************************/
;VOID   _tx_thread_stack_build(TX_THREAD *thread_ptr, VOID (*function_ptr)(VOID))
;{
    .global __tx_thread_stack_build
__tx_thread_stack_build:
;
;
;    /* Build an interrupt frame.  The form of the fake interrupt stack
;       on the Renesas RX should look like the following after it is built:
;
;  Stack Top:           ACC0
;                       R6
;                       R7
;                       R8
;                       R9
;                       R10
;                       R11
;                       R12
;                       R13
;                       FPSW
;                       R14
;                       R15
;                       R3
;                       R4
;                       R5
;                       R1
;                       R2
;                       PC
;                       PSW

;
;    Stack Bottom: (higher memory address)  */
;
    MOV.L   16[R1],R3                            ; Pickup end of stack area
    BCLR    #0, R3                               ; Mask for 4-byte alignment
    BCLR    #1, R3
;
;    /* Build the stack frame.  */
;
    MOV.L #30000h, R4
    MOV.L R4, [-R3]                              ; Initial PSW (SVC mode, U flag set)
    MOV.L R2, [-R3]                              ; Initial PC
    MOV.L #0, R4
    MOV.L R4,[-R3]                               ; Initial R2 ...
    MOV.L R4,[-R3]                               ; Initial R1 ...
    MOV.L R4,[-R3]                               ; Initial R5 ...
    MOV.L R4,[-R3]                               ; Initial R4 ...
    MOV.L R4,[-R3]                               ; Initial R3 ...
    MOV.L R4,[-R3]                               ; Initial R15 ...
    MOV.L R4,[-R3]                               ; Initial R14 ...
    MOV.L R4,[-R3]                               ; Initial R13 ...
    MOV.L R4,[-R3]                               ; Initial R12 ...
    MOV.L R4,[-R3]                               ; Initial R11 ...
    MOV.L R4,[-R3]                               ; Initial R10 ...
    MOV.L R4,[-R3]                               ; Initial R9 ...
    MOV.L R4,[-R3]                               ; Initial R8 ...
    MOV.L R4,[-R3]                               ; Initial R7 ...
    MOV.L R4,[-R3]                               ; Initial R6 ...

    MOV.L R4,[-R3]                               ; Accumulator 0
    MOV.L R4,[-R3]

;    /* Setup stack pointer.  */
;    thread_ptr -> tx_thread_stack_ptr =  R1;
    MOV.L R3, 8[R1]
                                                 ; Store initial SP in thread control block
    RTS

;}
    .end
