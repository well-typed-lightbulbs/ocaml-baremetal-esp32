// Copyright 2015-2016 Espressif Systems (Shanghai) PTE LTD
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/*
 * Log library implementation notes.
 *
 * Log library stores all tags provided to esp_log_level_set as a linked
 * list. See uncached_tag_entry_t structure.
 *
 * To avoid looking up log level for given tag each time message is
 * printed, this library caches pointers to tags. Because the suggested
 * way of creating tags uses one 'TAG' constant per file, this caching
 * should be effective. Cache is a binary min-heap of cached_tag_entry_t
 * items, ordering is done on 'generation' member. In this context,
 * generation is an integer which is incremented each time an operation
 * with cache is performed. When cache is full, new item is inserted in
 * place of an oldest item (that is, with smallest 'generation' value).
 * After that, bubble-down operation is performed to fix ordering in the
 * min-heap.
 *
 * The potential problem with wrap-around of cache generation counter is
 * ignored for now. This will happen if someone happens to output more
 * than 4 billion log entries, at which point wrap-around will not be
 * the biggest problem.
 *
 */

#include "esp_attr.h"
#include "xtensa/hal.h"
#include "soc/soc.h"
#include <stdbool.h>
#include <stdarg.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <ctype.h>

#include "esp_log.h"

#include "sys/queue.h"
#include "soc/soc_memory_layout.h"

//print number of bytes per line for esp_log_buffer_char and esp_log_buffer_hex
#define BYTES_PER_LINE 16

//the variable defined in ROM is the cpu frequency in MHz.
//as a workaround before the interface for this variable
extern uint32_t g_ticks_per_us_pro;

uint32_t esp_log_early_timestamp()
{
    return xthal_get_ccount() / (g_ticks_per_us_pro * 1000);
}
#define BOOTLOADER_BUILD

uint32_t esp_log_timestamp() __attribute__((alias("esp_log_early_timestamp")));

