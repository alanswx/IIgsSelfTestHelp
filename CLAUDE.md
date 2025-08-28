# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Apple IIGS ProDOS 8 program that launches the built-in ROM diagnostic Test #6 (Serial Chip). The program is written in 65816 assembly language and uses the Merlin32 cross-assembler.

## Build System

**Primary build command:**
```bash
make
```

**Clean build artifacts:**
```bash
make clean
```

The build system uses Merlin32 assembler with the `-V` flag to include the macro library. Output files are automatically generated with quotes around the filename due to ProDOS 8 conventions.

## Architecture

### Assembly Structure
- **Entry Point:** Program starts at $2000 (standard ProDOS 8 location)
- **Mode Switching:** Code transitions from 8-bit emulation mode to 16-bit native mode to call ROM diagnostics, then switches back
- **Memory Layout:** Uses zero page variables at $06-$07 for indirect addressing

### Key Components
- **ROM Interface:** Accesses Apple IIGS ROM diagnostic table at $FF7402
- **ProDOS 8 MLI:** Uses Machine Language Interface for system calls (entry at $BF00)
- **Monitor Routines:** Leverages built-in monitor COUT routine at $FDED for output
- **Status Reporting:** Uses 5-byte status area at $0315 for diagnostic results

### Critical Memory Addresses
- `DIAG_TABLE` ($FF7402): ROM diagnostic pointer table
- `TST_STATUS` ($0315): 5-byte diagnostic status area
- `PRINT_PTR` ($06): Zero page pointer for string printing
- `MLI` ($BF00): ProDOS Machine Language Interface
- `COUT` ($FDED): Monitor character output routine

## Development Notes

### Addressing Mode Requirements
- Indirect indexed addressing `(ptr),Y` requires pointers in zero page ($00-$FF)
- The assembler will error if pointers are placed outside zero page for this addressing mode

### Assembly Directives
- `ORG $2000`: Standard ProDOS 8 program start address
- `DSK 'filename'`: Sets output binary filename
- `TYP 'SYS'`: Sets ProDOS file type to SYS ($F1)
- `MX %11`: Sets default to 8-bit accumulator and index registers

### Merlin32 Toolchain
The project includes a complete Merlin32 v1.2 beta 2 installation with:
- Cross-platform executables (Linux/MacOS/Windows)
- Comprehensive macro library for Apple IIGS development
- Support for 65816 processor instructions and addressing modes

### Output Files
Building generates several files:
- `'RUNTEST6.P8'`: Main executable binary
- `'RUNTEST6.P8'_S01_Segment1_Output.txt`: Assembly listing
- `'RUNTEST6.P8'_Symbols.txt`: Symbol table
- `_FileInformation.txt`: ProDOS file attributes