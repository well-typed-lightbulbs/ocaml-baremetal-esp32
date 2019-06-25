// Copyright 2015-2016 Espressif Systems (Shanghai) PTE LTD
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

#include "esp_log.h"
#include "esp32/rom/gpio.h"
#include "esp32/rom/spi_flash.h"
#include "bootloader_config.h"
#include "bootloader_init.h"
#include "bootloader_utility.h"
#include "bootloader_common.h"
#include "sdkconfig.h"
#include "esp_image_format.h"

#include "soc/rtc.h"


extern char _heap_end;
extern char _heap_start;
extern char _bss_start;
extern char _bss_end;

extern void caml_startup(const char** argv);
extern void _nolibc_init(uintptr_t heap_start, int heap_size);

void bootloader_reset(void)
{
    uart_tx_flush(0);    /* Ensure any buffered log output is displayed */
    uart_tx_flush(1);
    ets_delay_us(1000); /* Allow last byte to leave FIFO */
    REG_WRITE(RTC_CNTL_OPTIONS0_REG, RTC_CNTL_SW_SYS_RST);
    while (1) { }
}

/*
 * We arrive here after the ROM bootloader finished loading this second stage bootloader from flash.
 * The hardware is mostly uninitialized, flash cache is down and the app CPU is in reset.
 * We do have a stack, so we can do the initialization in C.
 */
void __attribute__((noreturn)) call_start_cpu0()
{
    asm volatile ("mov sp, %0;" :: "r" (&_bss_start));

    // 1. Hardware initialization
    if (bootloader_init() != ESP_OK) {
        bootloader_reset();
    }

    // init nolibc of ocaml_freestanding
    uintptr_t start = (uintptr_t) &_heap_start;
    uintptr_t size = (uintptr_t) &_heap_end - (uintptr_t)&_heap_start;

    _nolibc_init(start, size);
    ets_printf("Booting ESP32 with %d bytes of dynamic memory.\n", size);

    const char *argv[2] = { "ocaml-boot-esp32", 0 };

    // call ocaml land
    caml_startup(argv);

    ets_printf("Fini!\n");
    while(1) {}
}
/*
// Return global reent struct if any newlib functions are linked to bootloader
struct _reent* __getreent() {
    return _GLOBAL_REENT;
}*/

