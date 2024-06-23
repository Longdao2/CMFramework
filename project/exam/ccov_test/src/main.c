/**
* @file     main.c
* @author   Long Dao [https://louisvn.com]
* @version  2.0.0
* @date     07-01-2024
* @brief    Example: Run the tests and measure code coverage
*/

/** -----------------------------------------------------------------------
>>>                                Includes
--------------------------------------------------------------------------- */
#include "main.h"

/** -----------------------------------------------------------------------
>>>                              Main function
--------------------------------------------------------------------------- */
int main( void )
{
    printf("* This example will run tests to measure the coverage of function 'check_hex':\n");
    UT_RunTests();

    return 0;
}

/** -----------------------------------------------------------------------
>>>                               End of file
--------------------------------------------------------------------------- */
