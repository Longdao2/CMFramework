/**
* @file     main.h
* @author   Long Dao [https://louisvn.com]
* @version  1.0.8
* @date     02-15-2024
* @brief    Example: Run the tests and measure code coverage
*/

#ifndef _MAIN_H_
#define _MAIN_H_

#ifdef __cplusplus
extern "C" {
#endif /* cpp */

/** -----------------------------------------------------------------------
>>>                                Includes
--------------------------------------------------------------------------- */
#include <stdio.h>
#include "check_hexa.h"
#include "utest.h"

/** -----------------------------------------------------------------------
>>>                                  APIs
--------------------------------------------------------------------------- */
FuncTest(EXAMPLE_TC_01);
FuncTest(EXAMPLE_TC_02);
FuncTest(EXAMPLE_TC_03);
FuncTest(EXAMPLE_TC_04);


#ifdef __cplusplus
}
#endif /* cpp */
#endif /* _MAIN_H_ */

/** -----------------------------------------------------------------------
>>>                               End of file
--------------------------------------------------------------------------- */
