/**
* @file     check_hexa.h
* @author   Long Dao [https://louisvn.com]
* @version  2.0.0
* @date     07-01-2024
* @brief    API for checking if a string is a hexadecimal
*/

#ifndef _CHECK_HEXA_H_
#define _CHECK_HEXA_H_

#ifdef __cplusplus
extern "C" {
#endif /* cpp */

/** -----------------------------------------------------------------------
>>>                                  APIs
--------------------------------------------------------------------------- */

/**
* @brief Used to check if a string is in hexadecimal format
* @param [in] buff -- any string
* @return int -- [1] if the input is a hexadecimal string. [0] if it's not
*/
int check_hex(const char buff[]);


#ifdef __cplusplus
}
#endif /* cpp */
#endif /* _CHECK_HEXA_H_ */

/** -----------------------------------------------------------------------
>>>                               End of file
--------------------------------------------------------------------------- */
