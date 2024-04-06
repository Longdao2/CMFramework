/**
* @file     main.c
* @author   Long Dao [https://louisvn.com]
* @version  1.0.9
* @date     04-10-2024
* @brief    Example: Run tests with GDB script
*/

/** -----------------------------------------------------------------------
>>>                                Includes
--------------------------------------------------------------------------- */
#include "main.h"

/** -----------------------------------------------------------------------
>>>                               Definitions
--------------------------------------------------------------------------- */
UT_DEF_S
UT_AddTest( GDBSCRIPT_TC_01, "Escape the condition deadlock in the while loop" )
UT_DEF_E

/** -----------------------------------------------------------------------
>>>                                Variables
--------------------------------------------------------------------------- */
volatile int INTERRUPT_STATE = 0;

/** -----------------------------------------------------------------------
>>>                              Main function
--------------------------------------------------------------------------- */
int main( void )
{
    printf
    (
        "* This example allows running a stuck program.\n"
        "* Then using a GDB script to break it out of the infinite loop.\n"
    );

    UT_RunTests();

    return 0;
}

/** -----------------------------------------------------------------------
>>>                              Sub functions
--------------------------------------------------------------------------- */
void Wait_Finish( void )
{
    while ( 1 == INTERRUPT_STATE )
    {
        /* Wait until the interrupt status has been cleared */
    }
}

/** -----------------------------------------------------------------------
>>>                             Test functions
--------------------------------------------------------------------------- */
FuncTest( GDBSCRIPT_TC_01 )
{
    /* # 01. The interrupt status is not set. So, it'll pass through */
    UT_Assert( 0 == INTERRUPT_STATE );
    /* Invoke the "Wait_Finish" function to verify */
    Wait_Finish();
    /* Check the interrupt flag status again to ensure it has been cleared */
    UT_Assert( 0 == INTERRUPT_STATE );

    /* # 02. Assuming that the interrupt status is set, it'll be stuck in the while loop */
    INTERRUPT_STATE = 1;
    UT_Assert( 1 == INTERRUPT_STATE );
    /* NOTE. I will use a GDB script to intervene in the while loop */
    /* Then, reset the state of "INTERRUPT_STATE" */
    UT_InjectionPoint( GDBSCRIPT_TC_01_TP01 );
    Wait_Finish();
    /* Check the interrupt flag status again to ensure it has been cleared */
    UT_Assert( 0 == INTERRUPT_STATE );
}

/** -----------------------------------------------------------------------
>>>                               End of file
--------------------------------------------------------------------------- */
