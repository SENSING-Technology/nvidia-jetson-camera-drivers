#include <check.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <signal.h>
#include <setjmp.h>

/* Mock the sprintf wrapper to detect buffer overflow */
static jmp_buf overflow_env;
static int overflow_detected = 0;

/* Simulate the vulnerable sprintf pattern from sensor_common.c */
int test_sprintf_wrapper(char *pix_format, size_t buf_size, 
                         const char *mode_str, const char *phase_str, int depth)
{
    /* This mimics the vulnerable code: sprintf without bounds checking */
    return snprintf(pix_format, buf_size, "%s_%s%d", mode_str, phase_str, depth);
}

void segfault_handler(int sig)
{
    overflow_detected = 1;
    longjmp(overflow_env, 1);
}

START_TEST(test_buffer_read_bounds_sprintf)
{
    /* Invariant: Buffer reads never exceed declared length */
    
    struct {
        const char *mode_str;
        const char *phase_str;
        int depth;
        const char *description;
    } payloads[] = {
        /* Exploit: oversized strings (10x buffer capacity) */
        {"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", 
         "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB", 
         12345, "oversized_10x"},
        
        /* Boundary: exactly at buffer edge (64 bytes typical) */
        {"AAAAAAAAAAAAAAAAAAAAAAAAAAAA", 
         "BBBBBBBBBBBBBBBBBBBBBBBBBBBB", 
         99, "boundary_64"},
        
        /* Valid: normal input within bounds */
        {"RAW", "PHASE", 8, "valid_normal"},
        
        /* Boundary: 2x oversized */
        {"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", 
         "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB", 
         999, "oversized_2x"}
    };
    
    int num_payloads = sizeof(payloads) / sizeof(payloads[0]);
    char pix_format[64];
    
    signal(SIGSEGV, segfault_handler);
    
    for (int i = 0; i < num_payloads; i++) {
        overflow_detected = 0;
        memset(pix_format, 0, sizeof(pix_format));
        
        if (setjmp(overflow_env) == 0) {
            int ret = test_sprintf_wrapper(pix_format, sizeof(pix_format),
                                          payloads[i].mode_str,
                                          payloads[i].phase_str,
                                          payloads[i].depth);
            
            /* Invariant: return value must not exceed buffer size */
            ck_assert_int_le(ret, (int)sizeof(pix_format) - 1);
            
            /* Invariant: no segfault or buffer overflow occurred */
            ck_assert_int_eq(overflow_detected, 0);
            
            /* Invariant: buffer remains null-terminated */
            ck_assert(pix_format[sizeof(pix_format) - 1] == '\0' || 
                     strlen(pix_format) < sizeof(pix_format));
        } else {
            ck_abort_msg("Buffer overflow detected on payload: %s", 
                        payloads[i].description);
        }
    }
}
END_TEST

Suite *security_suite(void)
{
    Suite *s;
    TCase *tc_core;

    s = suite_create("Security");
    tc_core = tcase_create("BufferBounds");

    tcase_add_test(tc_core, test_buffer_read_bounds_sprintf);
    suite_add_tcase(s, tc_core);

    return s;
}

int main(void)
{
    int number_failed;
    Suite *s;
    SRunner *sr;

    s = security_suite();
    sr = srunner_create(s);

    srunner_run_all(sr, CK_NORMAL);
    number_failed = srunner_ntests_failed(sr);
    srunner_free(sr);

    return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}