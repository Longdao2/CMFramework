/**
* @file     utest.c
* @author   Long Dao [https://louisvn.com]
* @version  2.0.0
* @date     07-01-2024
* @brief    Extension for testing (used for compilation)
*/

/** -----------------------------------------------------------------------
>>>                                Includes
--------------------------------------------------------------------------- */
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <profileapi.h>
#include "utest.h"

/** -----------------------------------------------------------------------
>>>                                Processes
--------------------------------------------------------------------------- */

#ifdef UTEST_SUPPORT

#define UT_SET_START \
    FILE * f = fopen(REPORT_RAW, "a"); \
    if (NULL != f) {

#define UT_SET_END \
        (void)fclose(f); \
    } else { \
        printf("\n> UT_ERROR : Can not open \"%s\"\n", REPORT_RAW); \
    }

static LARGE_INTEGER s_freq, s_start, s_end;
static unsigned int s_id = 0U;

void UT_Init(void)
{
    time_t currentTime;
    struct tm *localTime;
    char formattedTime[20U];

    s_id = 0U;
    currentTime = time(NULL);
    localTime = localtime(&currentTime);
    if (NULL != localTime)
    {
        (void)strftime(formattedTime, sizeof(formattedTime), "%H:%M:%S %m-%d-%Y", localTime);
    }
    else
    {
        (void)strcpy(formattedTime, "00:00:00 00-00-0000");
    }

    (void)remove(REPORT_RAW);
    UT_SetVar_Str("exe_time", formattedTime);
    UT_SetVar_Str("user_name", USER_NAME);
    UT_SetVar_Str("proj_name", PROJ_NAME);
}

void DU_Init(void)
{
    (void)QueryPerformanceFrequency(&s_freq);
}

void UT_SetId(unsigned int id)
{
    s_id = id;
}

void UT_SetBrief(const char brief[])
{
    UT_SET_START
        fprintf(f, "%u.brief = %.*s\n", s_id, (int)strlen(brief) - 2, brief + 1U);
    UT_SET_END
}

void UT_SetVar_Str(const char varname[], const char value[])
{
    UT_SET_START
        fprintf(f, "%u.%s = %s\n", s_id, varname, value);
    UT_SET_END
}

void UT_SetVar_Num(const char varname[], unsigned int value)
{
    UT_SET_START
        fprintf(f, "%u.%s = %u\n", s_id, varname, value);
    UT_SET_END
}

void UT_AddFail(const char file[], const char func[], int line)
{
    UT_SET_START
        fprintf(f, "%u.fail = %s - Func: %s - Line: %d<br>\n", s_id, file, func, line);
    UT_SET_END
}

void DU_Start(void)
{
    (void)QueryPerformanceCounter(&s_start);
}

void DU_End(void)
{
    (void)QueryPerformanceCounter(&s_end);
}

double DU_GetValue(void)
{
    return ((double)(s_end.QuadPart - s_start.QuadPart) / s_freq.QuadPart) * 1000000.0;
}

#endif /* UTEST_SUPPORT */

/** -----------------------------------------------------------------------
>>>                               End of file
--------------------------------------------------------------------------- */
