/**
* @file     check_hexa.c
* @author   Long Dao [https://louisvn.com]
* @version  1.0.8
* @date     02-15-2024
* @brief    Check if a string is hexadecimal
*/

/** -----------------------------------------------------------------------
>>>                                Includes
--------------------------------------------------------------------------- */
#include "check_hexa.h"

/** -----------------------------------------------------------------------
>>>                            Global functions
--------------------------------------------------------------------------- */
int check_hex(const char buff[])
{
    int index = 0;
    int retval = 0;

    if (((void *)0 != buff) && (0 != buff[0]))
    {
        retval = 1;
        for (/* index = 0 */; (1 == retval) && (0 != buff[index]); index++)
        {
            if ((buff[index] < '0' || buff[index] > '9') &&
                (buff[index] < 'a' || buff[index] > 'f') &&
                (buff[index] < 'A' || buff[index] > 'F'))
            {
                retval = 0;
            }
        }
    }

    return retval;
}

/** -----------------------------------------------------------------------
>>>                               End of file
--------------------------------------------------------------------------- */
