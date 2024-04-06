/**
* @file     utest.c
* @author   Long Dao [https://louisvn.com]
* @version  1.0.9
* @date     04-10-2024
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
    FILE * f = fopen(s_file, "a"); \
    if (NULL != f) {

#define UT_SET_END \
    } else { \
        printf("\n> UT_ERROR : Can not open \"%s\"\n", s_file); \
        exit(111); \
    } fclose(f);

static LARGE_INTEGER s_freq, s_start, s_end;
static char *s_file = NULL;
static unsigned int s_id = 0U;

void UT_Init(void)
{
    time_t currentTime;
    struct tm *localTime;
    char formattedTime[20U];

    s_id = 0U;
    s_file = getenv("REPORT_RAW");
    currentTime = time(NULL);
    localTime = localtime(&currentTime);
    strftime(formattedTime, sizeof(formattedTime), "%H:%M:%S %m-%d-%Y", localTime);

    remove(s_file);
    UT_SetVar_Str("exe_time", formattedTime);
    UT_SetVar_Str("user_name", getenv("USER_NAME"));
    UT_SetVar_Str("proj_name", getenv("PROJ_NAME"));
}

void DU_Init(void)
{
    QueryPerformanceFrequency(&s_freq);
}

void UT_SetId(unsigned int id)
{
    s_id = id;
}

void UT_SetBrief(const char brief[])
{
    UT_SET_START
        fprintf(f, "%d.brief = %.*s\n", s_id, (int)strlen(brief) - 2U, brief + 1U);
    UT_SET_END
}

void UT_SetVar_Str(const char varname[], const char value[])
{
    UT_SET_START
        fprintf(f, "%d.%s = %s\n", s_id, varname, value);
    UT_SET_END
}

void UT_SetVar_Num(const char varname[], unsigned int value)
{
    UT_SET_START
        fprintf(f, "%d.%s = %d\n", s_id, varname, value);
    UT_SET_END
}

void UT_AddFail(const char file[], const char func[], int line)
{
    UT_SET_START
        fprintf(f, "%d.fail = %s - Func: %s - Line: %d<br>\n", s_id, file, func, line);
    UT_SET_END
}

void DU_Start(void)
{
    QueryPerformanceCounter(&s_start);
}

void DU_End(void)
{
    QueryPerformanceCounter(&s_end);
}

double DU_GetValue(void)
{
    return ((double)(s_end.QuadPart - s_start.QuadPart) / s_freq.QuadPart) * 1000000.0;
}

#endif /* UTEST_SUPPORT */

/** -----------------------------------------------------------------------
>>>                               End of file
--------------------------------------------------------------------------- */
