payload.o: app.ml
	/home/lucas/.opam/mirage-32/esp32-sysroot/bin/ocamlopt $< -output-obj $(OCAMLFLAGS) -o $@

.PHONY: clean
clean:
	rm -f *.o *.cmx
