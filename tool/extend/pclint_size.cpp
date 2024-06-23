#include <stdio.h>

int main(void)
{
    printf("-ss%d ", (int)sizeof(short));
    printf("-si%d ", (int)sizeof(int));
    printf("-sl%d ", (int)sizeof(long));
    printf("-sll%d ", (int)sizeof(long long));
    printf("-sf%d ", (int)sizeof(float));
    printf("-sd%d ", (int)sizeof(double));
    printf("-sld%d ", (int)sizeof(long double));
    printf("-sp%d ", (int)sizeof(void*));
    printf("-sw%d\n", (int)sizeof(wchar_t));

    return 0;
}
