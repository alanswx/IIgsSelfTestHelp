# Makefile for assembling with Merlin32

# --- Variables ---
ASM = ./Merlin32_v1.2_b2/Linux/Merlin32
CP2 = ./cp2_1.1.0_linux-x64_sc/cp2
DISK = systemdisk.2mg

# Source files and targets for all tests
SOURCES = RUNTEST1.P8.S RUNTEST2.P8.S RUNTEST3.P8.S RUNTEST4.P8.S RUNTEST5.P8.S \
          RUNTEST6.P8.S RUNTEST7.P8.S RUNTEST8.P8.S RUNTEST9.P8.S RUNTEST10.P8.S RUNTEST11.P8.S
TARGETS = RUNTEST1.P8 RUNTEST2.P8 RUNTEST3.P8 RUNTEST4.P8 RUNTEST5.P8 \
          RUNTEST6.P8 RUNTEST7.P8 RUNTEST8.P8 RUNTEST9.P8 RUNTEST10.P8 RUNTEST11.P8

# --- Rules ---

# Default rule: typing 'make' will build all tests and add them to disk
all: $(TARGETS) $(DISK)

# Generic rule to assemble any source file
# The DSK and TYP directives in the source file handle the output name and type,
# so we just need to point Merlin32 at the source.
%.P8: %.P8.S
	$(ASM) -V Merlin32_v1.2_b2/Library/ $<

# Rule to add all binaries to existing disk image
$(DISK): $(TARGETS)
	@for target in $(TARGETS); do \
		echo "Adding $$target to disk..."; \
		$(CP2) rm $(DISK) "$$target" 2>/dev/null || true; \
		$(CP2) add $(DISK) "$$target"; \
		$(CP2) sa $(DISK) type=SYS "$$target"; \
	done

# Individual test rules for convenience
test1: RUNTEST1.P8
test2: RUNTEST2.P8
test3: RUNTEST3.P8
test4: RUNTEST4.P8
test5: RUNTEST5.P8
test6: RUNTEST6.P8
test7: RUNTEST7.P8
test8: RUNTEST8.P8
test9: RUNTEST9.P8
test10: RUNTEST10.P8
test11: RUNTEST11.P8

# Rule to clean up the build output
clean:
	rm -f $(TARGETS)
	rm -f *_S01_Segment1_Output.txt
	rm -f *_Symbols.txt
	rm -f _FileInformation.txt

# Phony targets are not actual files
.PHONY: all clean test1 test2 test3 test4 test5 test6 test7 test8 test9 test10 test11

