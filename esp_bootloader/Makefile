CC=xtensa-esp32-elf-gcc
AR=xtensa-esp32-elf-ar

override CFLAGS+=-I ./include/ -DBOOTLOADER_BUILD

OBJS=$(patsubst %.c,%.o,$(wildcard src/*.c))

libboot.a: $(OBJS)
	$(AR) rcs $@ $^

.PHONY: clean
clean:
	rm -f libboot.a src/*.o
