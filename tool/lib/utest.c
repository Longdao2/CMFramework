/**
* @file     utest.c
* @author   Long Dao [admin@louisvn.com]
* @version  0.4
* @date     2023-11-05
* @brief    Extension for testing (build only)
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
>>>                               Build only
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
static int s_id = 0;

void UT_Init(void)
{
    time_t currentTime;
    struct tm *localTime;
    char formattedTime[20];

    s_id = 0;
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

void UT_SetId(int id)
{
    s_id = id;
}

void UT_SetBrief(const char brief[])
{
    UT_SET_START
        fprintf(f, "%d.brief = %.*s\n", s_id, strlen(brief) - 2, brief + 1);
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
    QueryPerformanceCounter( &s_start );
}

void DU_End(void)
{
    QueryPerformanceCounter( &s_end );
}

double DU_GetValue(void)
{
    return (( double )( s_end.QuadPart - s_start.QuadPart ) / s_freq.QuadPart ) * 1000000.0;
}

#endif /* UTEST_SUPPORT */

/** -----------------------------------------------------------------------
>>>                               End of file
--------------------------------------------------------------------------- */
