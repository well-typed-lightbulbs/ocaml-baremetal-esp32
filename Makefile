
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

CFLAGS=-Os -ffunction-sections -fdata-sections -isystem $(ROOT_DIR)/ocaml-freestanding/nolibc/include -mlongcalls
LDFLAGS=--gc-sections
OCAMLFLAGS=-use-lto
ESP32_PORT=/dev/ttyUSB1



TARGET=xtensa-esp32-elf
LD=$(TARGET)-ld

DEPS=app/payload.o esp_bootloader/libboot.a ocaml-esp32/asmrun/libasmrun.a ocaml-freestanding/nolibc/libnolibc.a sys_libs/libm.a sys_libs/libgcc.a

OPAM_SWITCH_ROOT=$(shell opam config var prefix)

all: app.elf

linker.ld: linker.ld.in
	gcc -E -x c $< | grep -v '^#' > $@

app.elf: $(DEPS) linker.ld
	$(LD) $(LDFLAGS) -T linker.ld -T rom.ld $(DEPS) -o $@

app.bin: app.elf
	esptool.py --chip esp32 elf2image --flash_mode="dio" --flash_freq "40m" --flash_size "4MB" -o app.bin app.elf

.PHONY: flash
flash: app.bin
	esptool.py --chip esp32 --port $(ESP32_PORT) --baud 460800 --before default_reset --after hard_reset write_flash -z \
		--flash_mode dio --flash_freq 40m --flash_size detect 0x1000 app.bin

.PHONY: monitor
monitor: vendor/idf_monitor.py
	python vendor/idf_monitor.py app.elf --port $(ESP32_PORT)

.PHONY: clean
clean:
	$(MAKE) -C app clean
	$(MAKE) -C esp_bootloader clean
	$(MAKE) -C ocaml-esp32 distclean || echo 1
	rm -f ./ocaml-frestanding/nolibc/*.o
	rm -f ./sys_libs/*.a


# PAYLOAD APPLICATION

.PHONY: app/payload.o
app/payload.o:
	$(MAKE) -C app OCAMLFLAGS="$(OCAMLFLAGS)" payload.o

# ESP32 BOOTLOADER

.PHONY: esp_bootloader/libboot.a
esp_bootloader/libboot.a:
	$(MAKE) -C esp_bootloader CFLAGS="$(CFLAGS)" libboot.a

# LIBASMRUN.A

ocaml-esp32/byterun/caml/s.h: ocaml-freestanding/config.in/s.h
	cp ocaml-freestanding/config.in/s.h ocaml-esp32/byterun/caml/s.h

ocaml-esp32/byterun/caml/m.h: ocaml-freestanding/config.in/m.xtensa.h
	cp ocaml-freestanding/config.in/m.xtensa.h ocaml-esp32/byterun/caml/m.h

ocaml-esp32/config/Makefile: ocaml-freestanding/config.in/Makefile.ESP32.xtensa
	cp ocaml-freestanding/config.in/Makefile.ESP32.xtensa ocaml-esp32/config/Makefile

ocaml-esp32/byterun/caml/version.h: ocaml-esp32/config/Makefile
	ocaml-esp32/tools/make-version-header.sh > $@

.PHONY: ocaml-esp32/asmrun/libasmrun.a
ocaml-esp32/asmrun/libasmrun.a: ocaml-esp32/byterun/caml/version.h ocaml-esp32/byterun/caml/m.h ocaml-esp32/byterun/caml/s.h
	$(MAKE) -C ocaml-esp32/asmrun CFLAGS="$(CFLAGS)" libasmrun.a

# LIBM.A

sys_libs/libm.a: $(OPAM_SWITCH_ROOT)/xtensa-esp32-elf/xtensa-esp32-elf/lib/libm.a
	cp $< $@

# LIBGCC.A

sys_libs/libgcc.a: $(OPAM_SWITCH_ROOT)/xtensa-esp32-elf/lib/gcc/xtensa-esp32-elf/5.2.0/libgcc.a
	cp $< $@

# LIBNOLIBC.A
.PHONY: ocaml-freestanding/nolibc/libnolibc.a
ocaml-freestanding/nolibc/libnolibc.a:
	$(MAKE) -C ocaml-freestanding/nolibc libnolibc.a CC=xtensa-esp32-elf-gcc FREESTANDING_CFLAGS="$(CFLAGS)" SYSDEP_OBJS=sysdeps_esp32.o
