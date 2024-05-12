/**
* @file     main.h
* @author   Long Dao [https://louisvn.com]
* @version  1.1.0
* @date     05-12-2024
* @brief    Example: Run tests with GDB script
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
#include "utest.h"

/** -----------------------------------------------------------------------
>>>                               Definitions
--------------------------------------------------------------------------- */

/** -----------------------------------------------------------------------
>>>                                  APIs
--------------------------------------------------------------------------- */

/**
* @brief Used to wait until the interrupt status is cleared
*/
void Wait_Finish( void );

FuncTest( GDBSCRIPT_TC_01 );

/** -----------------------------------------------------------------------
>>>                             Local functions
--------------------------------------------------------------------------- */


#ifdef __cplusplus
}
#endif /* cpp */
#endif /* _MAIN_H_ */

/** -----------------------------------------------------------------------
>>>                               End of file
--------------------------------------------------------------------------- */
