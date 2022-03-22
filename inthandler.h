/***********************************************************************/
/*                                                                     */
/*  FILE        :inthandler.h                                          */
/*  DATE        :Tue, Mar 22, 2022                                     */
/*  DESCRIPTION :Interrupt Handler Declarations                        */
/*  CPU TYPE    :H8S/Other                                             */
/*                                                                     */
/*  This file is generated by KPIT GNU Project Generator.              */
/*                                                                     */
/***********************************************************************/
     





#ifndef INTHANDLER_H
#define INTHANDLER_H

//;<<VECTOR DATA START (POWER ON RESET)>>
//;0 Power On Reset
//extern void PowerON_Reset(void);
//;<<VECTOR DATA END (POWER ON RESET)>>
//;<<VECTOR DATA START (MANUAL RESET)>>
//;1 Manual Reset
//extern void Manual_Reset(void);
void INT_Manual_Reset(void)  __attribute__ ((interrupt_handler));

#endif

