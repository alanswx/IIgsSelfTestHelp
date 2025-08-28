# Apple IIGS Self-Test Programs

This directory contains Apple IIGS ProDOS 8 programs that launch the built-in ROM diagnostic tests. Each program is written in 65816 assembly language and uses the Merlin32 cross-assembler.

## Overview

The Apple IIGS ROM contains a diagnostic test table at address $FF7402 with 11 different hardware tests. These programs provide individual access to each test, allowing you to run specific diagnostics as needed.

## Available Tests

| Program | Test # | Description |
|---------|--------|-------------|
| `RUNTEST1.P8` | 1 | 128K ROM checksum |
| `RUNTEST2.P8` | 2 | RAM Moving Inversions |
| `RUNTEST3.P8` | 3 | Mega I/O Statereg softswitch test |
| `RUNTEST4.P8` | 4 | RAM Addressing |
| `RUNTEST5.P8` | 5 | FPI fast/slow mode check |
| `RUNTEST6.P8` | 6 | Serial Chip |
| `RUNTEST7.P8` | 7 | Real Time Clock |
| `RUNTEST8.P8` | 8 | Battery RAM |
| `RUNTEST9.P8` | 9 | Front Desk Bus |
| `RUNTEST10.P8` | 10 | Shadow |
| `RUNTEST11.P8` | 11 | Interrupts |

## Building

### Build All Tests
```bash
make
```
This builds all 11 test programs and adds them to the system disk image.

### Build Individual Tests
```bash
make test1    # Build only Test 1 (128K ROM)
make test2    # Build only Test 2 (RAM Moving Inversions)
make test3    # Build only Test 3 (Mega I/O Softswitch)
# ... and so on for test4 through test11
```

### Clean Build Artifacts
```bash
make clean
```
Removes all compiled binaries and intermediate files.

## Architecture

### Program Structure
- **Entry Point:** All programs start at $2000 (standard ProDOS 8 location)
- **Mode Switching:** Programs transition from 8-bit emulation mode to 16-bit native mode to call ROM diagnostics, then switch back
- **Memory Layout:** Uses zero page variables at $06-$07 for indirect addressing

### Key Memory Addresses
- `DIAG_TABLE` ($FF7402): ROM diagnostic pointer table
- `TST_STATUS` ($0315): 5-byte diagnostic status area
- `PRINT_PTR` ($06): Zero page pointer for string printing
- `MLI` ($BF00): ProDOS Machine Language Interface
- `COUT` ($FDED): Monitor character output routine

### Test Results
Each program displays either:
- `Test X (Description): PASS` - Test completed successfully
- `Test X (Description): FAIL` - Test detected a problem

## Files

### Source Files
- `RUNTEST1.P8.S` through `RUNTEST11.P8.S` - Assembly source code
- `selftestsnippet.txt` - ROM diagnostic table reference
- `Makefile` - Build configuration

### Build System
- `Merlin32_v1.2_b2/` - Complete Merlin32 cross-assembler toolchain
- `cp2_1.1.0_linux-x64_sc/` - CiderPress2 disk utility for ProDOS images

### Output Files (Generated)
- `RUNTEST1.P8` through `RUNTEST11.P8` - Compiled binaries
- `*_S01_Segment1_Output.txt` - Assembly listings
- `*_Symbols.txt` - Symbol tables
- `_FileInformation.txt` - ProDOS file attributes
- `systemdisk.2mg` - Updated disk image with all programs

## Usage on Apple IIGS

1. Transfer the `systemdisk.2mg` disk image to your Apple IIGS
2. Boot from the disk or access it as a secondary disk
3. Run any test program from the ProDOS command line:
   ```
   ]RUNTEST1.P8
   ]RUNTEST6.P8
   etc.
   ```

## Technical Notes

- Programs use the ROM's native diagnostic routines via JSL (Jump to Subroutine Long)
- The test number is multiplied by 2 to index into the 16-bit pointer table
- All programs follow the same structure for consistency and maintainability
- Error status information is available in the 5-byte status area at $0315 after test completion

## Development

The build system uses:
- **Merlin32** v1.2 beta 2 for 65816 assembly
- **CiderPress2** for disk image management
- Cross-platform support (Linux/MacOS/Windows executables included)

For more detailed development information, see `CLAUDE.md`.