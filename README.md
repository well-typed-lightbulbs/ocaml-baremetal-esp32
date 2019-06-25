# ocaml-bare-esp32

Bare metal, ESP-IDF free, OCaml running on ESP32 devices.

## esp_bootloader: libboot.a

Contains the entry point in `bootloader_start.c`. This is taken from ESP-IDF because I don't know much about what's needed and what's not in ESP32 hardware initialization.
It then calls OCaml runtime's entry point `caml_startup` provided by `libasmrun.a`.

## libm.a libgcc.a

Provided with xtensa gcc toolchain.

## ocaml-freestanding: libnolibc.a

Minimal standard library.

## ocaml-esp32: libasmrun.a

OCaml runtime.

## app: payload.o

OCaml application payload.

# Installation

* `git clone --recursive --depth 1 https://github.com/well-typed-lightbulbs/ocaml-baremetal-esp32`: clone this repo and submodules.
* `opam switch create mirage-32 ocaml-variants.4.07.1+32bit`: need a 32-bit compiler switch for OCaml to build on esp32. The name is hardcoded in `app/Makefile`.
* `opam remote add esp https://github.com/well-typed-lightbulbs/opam-cross-esp32`: opam repository containing ESP32 cross-compilation tools.
* `opam install gcc-toolchain-esp32 ocaml-esp32`: GCC toolchain and OCaml cross-compiler for ESP32.

# Compilation/execution

* `make`: builds `app.elf`.
* `make flash`: converts `app.elf` to `app.bin` and flashes it to the board -- you can tweak `ESP32_PORT` in `Makefile`.
* `make monitor`: opens the serial port -- Ctrl+] to leave.

# Debugging

ESP32 has a JTAG interface that you can use to debug the processor with `gdb`. For ESP-WROVER kits it's JTAG over USB, so you don' need another cable.
For more information: https://docs.espressif.com/projects/esp-idf/en/latest/api-guides/jtag-debugging/