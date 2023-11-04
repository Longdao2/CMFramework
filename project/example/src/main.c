/**
* @file     main.c
* @author   Long Dao [admin@louisvn.com]
* @version  0.1
* @date     2023-11-05
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
