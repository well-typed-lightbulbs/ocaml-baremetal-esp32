_heap_end = 0x40000000;

MEMORY
{

  iram_0_cache_0 (RX) : org = 0x40070000, len = 0x8000




  iram_0_cache_1 (RX) : org = 0x40078000, len = 0x8000


  iram_0 (RX) : org = 0x40080000, len = 0x20000


  iram_1 (RX) : org = 0x400A0000, len = 0x20000 - 0x20000


  iflash (RX) : org = 0x400D0018, len = 0x330000-0x18


  dram_1 (RW) : org = 0x3FFE0000, len = 0x20000


  dram_2 (RW) : org = 0x3FFAE000 + 0x2000, len = 0x2e200 - 0x2000
  dram_2_miss (R): org = 0x3FFDC200, len = 0x3e00


  dflash (R) : org = 0x3F400018, len = 0x400000-0x18
}


ENTRY(call_start_cpu0);


SECTIONS
{

  .iram_loader.text :
  {
    . = ALIGN (16);
    _loader_text_start = ABSOLUTE(.);
    *(.stub .gnu.warning .gnu.linkonce.literal.* .gnu.linkonce.t.*.literal .gnu.linkonce.t.*)
     *(.iram1 .iram1.*)
    *(.fini.literal)
    *(.fini)
    *(.gnu.version)
    _loader_text_end = ABSOLUTE(.);
  } > iram_0_cache_1

  .iram.text :
  {
    . = ALIGN (16);
    *(.entry.text)
    *(.init.literal)
    *(.init)
  } > iram_0



  .dram0.bss (NOLOAD) :
  {
    . = ALIGN (8);
    _bss_start = ABSOLUTE(.);
    *(.dynsbss)
    *(.sbss)
    *(.sbss.*)
    *(.gnu.linkonce.sb.*)
    *(.scommon)
    *(.sbss2)
    *(.sbss2.*)
    *(.gnu.linkonce.sb2.*)
    *(.dynbss)
    *(.bss)
    *(.bss.*)
    *(.gnu.linkonce.b.*)
    *(COMMON)
    . = ALIGN (8);
    _bss_end = ABSOLUTE(.);
  } >dram_2

  .dram0.data :
  {
    _data_start = ABSOLUTE(.);
    *(.data)
    *(.data.*)
    *(.gnu.linkonce.d.*)
    *(.data1)
    *(.sdata)
    *(.sdata.*)
    *(.gnu.linkonce.s.*)
    *(.sdata2)
    *(.sdata2.*)
    *(.gnu.linkonce.s2.*)
    *(.jcr)
    _data_end = ABSOLUTE(.);
  } >dram_2

  .dram0.rodata :
  {
    _rodata_start = ABSOLUTE(.);
    *(.rodata)
    *(.rodata.*)
    *(.gnu.linkonce.r.*)
    *(.rodata1)
    __XT_EXCEPTION_TABLE_ = ABSOLUTE(.);
    *(.xt_except_table)
    *(.gcc_except_table)
    *(.gnu.linkonce.e.*)
    *(.gnu.version_r)
    *(.eh_frame)
    . = (. + 3) & ~ 3;
    _rodata_end = ABSOLUTE(.);

    _lit4_start = ABSOLUTE(.);
    *(*.lit4)
    *(.lit4.*)
    *(.gnu.linkonce.lit4.*)
    _lit4_end = ABSOLUTE(.);
    . = ALIGN(4);
    _heap_start = ABSOLUTE(.);
  } >dram_2

  .iram.text :
  {
    _stext = .;
    _text_start = ABSOLUTE(.);
    *(.literal .text .literal.* .text.* .stub .gnu.warning .gnu.linkonce.literal.* .gnu.linkonce.t.*.literal .gnu.linkonce.t.*)
    *(.iram .iram.*)
    *(.fini.literal)
    *(.fini)
    *(.gnu.version)
    _text_end = ABSOLUTE(.);
    _etext = .;
  } > iram_0

}
