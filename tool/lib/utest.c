/**
* @file     utest.c
* @author   Long Dao [admin@louisvn.com]
* @version  0.2
* @date     2023-08-05
* @brief    Extension for testing (build only)
*/

/** -----------------------------------------------------------------------
>>>                                Includes
--------------------------------------------------------------------------- */
#include <string.h>
#include <stdlib.h>
#include "utest.h"

/** -----------------------------------------------------------------------
>>>                               Build only
--------------------------------------------------------------------------- */

#ifdef UTEST_SUPPORT

static char *sfile = NULL;

static char sfail[1001] = "";

void ut_init(const char file[])
{
    sfile = (char *)file;
}

void ut_setvar_s(uint_t index, const char varname[], const char value[])
{
    FILE * f = fopen(sfile, "a");

    if (NULL != f)
    {
        fprintf(f, "%d.%.30s = %.1000s\n", index, varname, value);
    }
    else
    {
        printf("\n> UT_ERROR : Can not open \"%s\"\n", sfile);
        exit(11);
    }

    fclose(f);
}

void ut_setvar(uint_t index, const char varname[], uint_t value)
{
    char buff[11] = "";

    sprintf(buff, "%d", value);
    ut_setvar_s(index, varname, buff);
}

void ut_addfail(uint_t line)
{
    char _sfail[12] = "";
    sprintf(_sfail, " %d", line);
    if ((strlen(sfail) + strlen(_sfail)) < sizeof(sfail))
    {
        strcat(sfail, _sfail);
    }
}

char *ut_getfail(void)
{
    return sfail;
}

void ut_resetfail(void)
{
    *sfail = 0;
}

#endif /* UTEST_SUPPORT */

/** -----------------------------------------------------------------------
>>>                               End of file
--------------------------------------------------------------------------- */
