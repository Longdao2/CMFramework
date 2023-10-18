/**
* @file     utest.h
* @author   Long Dao [admin@louisvn.com]
* @version  0.2
* @date     2023-08-05
* @brief    APIs to perform testing
*/

#ifndef _UTEST_H_
#define _UTEST_H_

#ifdef __cplusplus
extern "C" {
#endif /* cpp */

/** -----------------------------------------------------------------------
>>>                                Includes
--------------------------------------------------------------------------- */
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "duration.h"

/** -----------------------------------------------------------------------
>>>                               Definitions
--------------------------------------------------------------------------- */
#define uint_t unsigned int

/** -----------------------------------------------------------------------
>>>                                  APIs
--------------------------------------------------------------------------- */

/**
* @brief Template to create a test function
* @param [in] name_func -- The function name cannot be longer than 100 characters
*/
#define FuncTest(name_func) void name_func(void)


#ifndef UTEST_SUPPORT

/**
* @brief Start defining a test list
*/
#define UT_DEF_S


/**
* @brief Add test to test list
* @param [in] name_test -- Length no more than 100 characters
* @param [in] brief -- Length no more than 1000 characters
*/
#define UT_AddTest(name_test, brief)


/**
* @brief End defining a test list
*/
#define UT_DEF_E


/**
* @brief Run all tests in the test list one by one
*/
#define UT_RunTests()


/**
* @brief Verify the test is correct
* @param [in] condition -- Conditions for verifying correctness
*/
#define UT_Assert(condition)


/** -----------------------------------------------------------------------
>>>                               Build only
--------------------------------------------------------------------------- */

#else /* #ifdef UTEST_SUPPORT */

void ut_init(const char file[]);
void ut_setvar_s(uint_t index, const char varname[], const char value[]);
void ut_setvar(uint_t index, const char varname[], uint_t value);
void ut_addfail(uint_t line);
char *ut_getfail(void);
void ut_resetfail(void);

typedef void (*UT_FuncTest_t)(void);

typedef struct
{
    UT_FuncTest_t func;
    char * nameTest;
    char * brief;
} UT_TestCase_t;

/* ======================================================================== */

#define REPORT_RAW  getenv("REPORT_RAW")
#define USER_NAME   getenv("USER_NAME")
#define PROJ_NAME   getenv("PROJ_NAME")

/* ======================================================================== */

#define UT_DEF_S const UT_TestCase_t __ut_all_tests[] = {

/* ======================================================================== */

#define UT_AddTest(name_test, brief) \
    {name_test, (char *)#name_test, (char *)#brief},

/* ======================================================================== */

#define UT_DEF_E }; \
    const uint_t __ut_all_tests_size = sizeof(__ut_all_tests) / sizeof(__ut_all_tests[0]); \
    unsigned char __ut_test_checker = 0; \
    \
    __attribute__((constructor)) void custom_startup(void) { \
        extern const UT_TestCase_t __ut_all_tests[]; \
        extern const uint_t __ut_all_tests_size; \
        time_t currentTime; \
        struct tm *localTime; \
        char formattedTime[20]; \
        \
        /* Get Time */ \
        currentTime = time(NULL); \
        localTime = localtime(&currentTime); \
        strftime(formattedTime, sizeof(formattedTime), "%H:%M:%S %m-%d-%Y", localTime); \
        \
        /* Write File */ \
        remove(REPORT_RAW); \
        ut_init(REPORT_RAW); \
        ut_setvar(0, "all_test", __ut_all_tests_size); \
        ut_setvar_s(0, "exe_time", formattedTime); \
        ut_setvar_s(0, "user_name", USER_NAME); \
        ut_setvar_s(0, "proj_name", PROJ_NAME); \
        for (uint_t index_case = 0; index_case < __ut_all_tests_size; index_case++) { \
            ut_setvar_s(index_case + 1, "name", __ut_all_tests[index_case].nameTest); \
            ut_setvar_s(index_case + 1, "brief", __ut_all_tests[index_case].brief); \
        } \
    }

/* ======================================================================== */

#define UT_Assert(condition) \
    extern unsigned char __ut_test_checker; \
    if (!(condition)) { \
        __ut_test_checker = 0; \
        ut_addfail(__LINE__); \
    }

/* ======================================================================== */

#define UT_RunTests() \
    extern const UT_TestCase_t __ut_all_tests[]; \
    extern const uint_t __ut_all_tests_size; \
    extern unsigned char __ut_test_checker; \
    duration_init(); \
    \
    /* Run and Update results */ \
    for (uint_t index_case = 0; index_case < __ut_all_tests_size; index_case++) { \
        ut_resetfail(); \
        printf("\n< FuncTest(\033[0;34m%s\033[0m): %s\n", __ut_all_tests[index_case].nameTest, __ut_all_tests[index_case].brief); \
        \
        /* Run test and get status */ \
        __ut_test_checker = 1; \
        duration_start(); \
        __ut_all_tests[index_case].func(); \
        duration_end(); \
        \
        /* Update status */ \
        ut_setvar(index_case + 1, "status", __ut_test_checker); \
        ut_setvar(index_case + 1, "duration", (uint_t)(DURATION_VALUE * 1000.0)); \
        \
        /* Display result */ \
        if (1 == __ut_test_checker) { \
            printf("\033[0;32m> PASS\033[0m\n"); \
        } \
        else { \
            ut_setvar_s(index_case + 1, "fail", ut_getfail()); \
            printf("\033[0;31m> FAIL\033[0m\n"); \
        } \
    }

/* ======================================================================== */

#endif /* UTEST_SUPPORT */
#ifdef __cplusplus
}
#endif /* cpp */
#endif /* _UTEST_H_ */

/** -----------------------------------------------------------------------
>>>                               End of file
--------------------------------------------------------------------------- */
