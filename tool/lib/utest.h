/**
* @file     utest.h
* @author   Long Dao [https://louisvn.com]
* @version  1.0.9
* @date     04-10-2024
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

/** -----------------------------------------------------------------------
>>>                               Definitions
--------------------------------------------------------------------------- */
#ifndef UT_ARGS_FILE_FUNC_LINE
#define UT_ARGS_FILE_FUNC_LINE  __FILE__, __func__, __LINE__
#endif /* ifndef UT_ARGS_FILE_FUNC_LINE */

/** -----------------------------------------------------------------------
>>>                                  APIs
--------------------------------------------------------------------------- */

/**
* @brief Use for debugging purposes. Failed assertions will jump in here
* @param [in] \p file - \p func - \p line : Stores some information of failure
*/
__attribute__((unused)) static inline void UT_IsFailure(const char file[], const char func[], int line);
__attribute__((unused)) static inline void UT_IsFailure(const char file[], const char func[], int line)
{
    void UT_AddFail(const char[], const char[], int); UT_AddFail(file, func, line);
}


/**
* @brief Template to create a test function
* @param [in] name_func -- Name of the test function
*/
#define FuncTest(name_func) void name_func(void)


#ifndef UTEST_SUPPORT

/**
* @brief Create a label in Assembly that can be used for debugging
* @param [in] label -- Name of label
* @attention Each label can only be defined once
*/
#define UT_InjectionPoint(label)


/**
* @brief Start defining a test list
* @attention A container must have at least one test
*/
#define UT_DEF_S


/**
* @brief Add test to test list
* @param [in] name_test -- Name of the function to be tested
* @param [in] brief -- Brief of this test (in quotes)
*/
#define UT_AddTest(name_test, brief)


/**
* @brief End defining a test list
* @attention A container must have at least one test
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
>>>                          Used for compilation
--------------------------------------------------------------------------- */

#else /* #ifdef UTEST_SUPPORT */

typedef void (* UT_FuncTest_t)(void);

typedef struct
{
    UT_FuncTest_t func;
    char * nameTest;
    char * brief;
}
UT_TestCase_t;

void UT_Init(void);
void DU_Init(void);
void UT_SetId(unsigned int id);
void UT_SetVar_Str(const char varname[], const char value[]);
void UT_SetVar_Num(const char varname[], unsigned int value);
void UT_AddFail(const char file[], const char func[], int line);
void UT_SetBrief(const char brief[]);
void DU_Start(void);
void DU_End(void);
double DU_GetValue(void);

extern const UT_TestCase_t __ut_all_tests[];
extern const unsigned int __ut_all_tests_size;
extern unsigned int __ut_test_checker;

/* ======================================================================== */

#define UT_InjectionPoint(label) asm volatile (#label":")

/* ======================================================================== */

#define UT_DEF_S const UT_TestCase_t __ut_all_tests[] = {

/* ======================================================================== */

#define UT_AddTest(name_test, brief) \
    {name_test, (char *)#name_test, (char *)#brief},

/* ======================================================================== */

#define UT_DEF_E }; \
    const unsigned int __ut_all_tests_size = sizeof(__ut_all_tests) / sizeof(__ut_all_tests[0U]); \
    unsigned int __ut_test_checker = 0U; \
    \
    __attribute__((constructor)) void custom_startup(void) { \
        UT_Init(); \
        UT_SetVar_Num("all_test", __ut_all_tests_size); \
        \
        for (unsigned int index_case = 0U; index_case < __ut_all_tests_size; index_case++) { \
            UT_SetId(index_case + 1U); \
            UT_SetVar_Str("name", __ut_all_tests[index_case].nameTest); \
            UT_SetBrief(__ut_all_tests[index_case].brief); \
        } \
    }

/* ======================================================================== */

#define UT_Assert(condition) \
    if (!(condition)) { \
        __ut_test_checker = 0U; \
        UT_IsFailure(UT_ARGS_FILE_FUNC_LINE); \
    }

/* ======================================================================== */

#define UT_RunTests() \
    DU_Init(); \
    \
    for (unsigned int index_case = 0U; index_case < __ut_all_tests_size; index_case++) { \
        UT_SetId(index_case + 1U); \
        printf("\n< FuncTest(\033[0;34m%s\033[0m): %s\n", __ut_all_tests[index_case].nameTest, __ut_all_tests[index_case].brief); \
        \
        /* Run test and get status */ \
        __ut_test_checker = 1U; \
        DU_Start(); \
        __ut_all_tests[index_case].func(); \
        DU_End(); \
        \
        /* Update status */ \
        UT_SetVar_Num("status", __ut_test_checker); \
        UT_SetVar_Num("duration", (unsigned int)DU_GetValue()); \
        \
        /* Display result */ \
        if (1U == __ut_test_checker) { \
            printf("\033[0;32m> PASS\033[0m\n"); \
        } \
        else { \
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
