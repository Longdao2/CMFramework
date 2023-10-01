/**
* @file     duration.h
* @author   Long Dao [admin@louisvn.com]
* @version  0.1
* @date     2023-09-26
* @brief    APIs to measure elapsed time
*/

#ifndef _DURATION_H_
#define _DURATION_H_

#ifdef __cplusplus
extern "C" {
#endif /* cpp */

/** -----------------------------------------------------------------------
>>>                                Includes
--------------------------------------------------------------------------- */
#include <profileapi.h>

/** -----------------------------------------------------------------------
>>>                               Definitions
--------------------------------------------------------------------------- */

/**
* @brief Use to init the clock
*/
#define duration_init() \
    LARGE_INTEGER __du_freq, __du_start, __du_end; \
    double __du_elapsed; \
    QueryPerformanceFrequency( &__du_freq );


/**
* @brief Use to start the performance timer
*/
#define duration_start() \
    QueryPerformanceCounter( &__du_start );


/**
* @brief Use to end the performance timer
*/
#define duration_end() \
    QueryPerformanceCounter( &__du_end ); \
    __du_elapsed = (( double )( __du_end.QuadPart - __du_start.QuadPart ) / __du_freq.QuadPart ) * 1000;


/**
* @brief Use to get results from previous performance timer
*/
#define DURATION_VALUE __du_elapsed


/** -----------------------------------------------------------------------
>>>                                  APIs
--------------------------------------------------------------------------- */

/** -----------------------------------------------------------------------
>>>                             Local functions
--------------------------------------------------------------------------- */


#ifdef __cplusplus
}
#endif /* cpp */
#endif /* _DURATION_H_ */

/** -----------------------------------------------------------------------
>>>                               End of file
--------------------------------------------------------------------------- */
