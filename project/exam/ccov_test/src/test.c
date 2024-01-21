/**
* @file     test.c
* @author   Long Dao [admin@louisvn.com]
* @version  1.0.7
* @date     01-20-2024
* @brief    Example: Run the tests and measure code coverage
*/

/** -----------------------------------------------------------------------
>>>                                Includes
--------------------------------------------------------------------------- */
#include "main.h"

/** -----------------------------------------------------------------------
>>>                               Definitions
--------------------------------------------------------------------------- */
UT_DEF_S
UT_AddTest(EXAMPLE_TC_01, "Validate function 'check_hex' with input as a NULL pointer")
UT_AddTest(EXAMPLE_TC_02, "Validate function 'check_hex' with input as a hexadecimal string")
UT_AddTest(EXAMPLE_TC_03, "Validate function 'check_hex' with input that is not a hexadecimal string")
UT_AddTest(EXAMPLE_TC_04, "Validate function 'check_hex' with input as an empty string")
UT_DEF_E

/** -----------------------------------------------------------------------
>>>                             Test functions
--------------------------------------------------------------------------- */

/* Validate function 'check_hex' with input as a NULL pointer */
FuncTest(EXAMPLE_TC_01)
{
    UT_Assert(0 == check_hex((void *)0));
}

/* Validate function 'check_hex' with input as a hexadecimal string */
FuncTest(EXAMPLE_TC_02)
{
    UT_Assert(1 == check_hex("01ABef5C"));
}

/* Validate function 'check_hex' with input that is not a hexadecimal string */
FuncTest(EXAMPLE_TC_03)
{
    UT_Assert(0 == check_hex("01ABeg5C"));
}

/* Validate function 'check_hex' with input as an empty string */
FuncTest(EXAMPLE_TC_04)
{
    UT_Assert(0 == check_hex(""));
}

/** -----------------------------------------------------------------------
>>>                               End of file
--------------------------------------------------------------------------- */
