/**
* @file     test.c
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
>>>                               Prototypes
--------------------------------------------------------------------------- */
static FuncTest(EXAMPLE_TC_01);
static FuncTest(EXAMPLE_TC_02);
static FuncTest(EXAMPLE_TC_03);
static FuncTest(EXAMPLE_TC_04);

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
static FuncTest(EXAMPLE_TC_01)
{
    UT_Assert(0 == check_hex((void *)0));
}

/* Validate function 'check_hex' with input as a hexadecimal string */
static FuncTest(EXAMPLE_TC_02)
{
    UT_Assert(1 == check_hex("01ABef5C"));
}

/* Validate function 'check_hex' with input that is not a hexadecimal string */
static FuncTest(EXAMPLE_TC_03)
{
    UT_Assert(0 == check_hex("01ABeg5C"));
}

/* Validate function 'check_hex' with input as an empty string */
static FuncTest(EXAMPLE_TC_04)
{
    UT_Assert(0 == check_hex(""));
}

/** -----------------------------------------------------------------------
>>>                               End of file
--------------------------------------------------------------------------- */
