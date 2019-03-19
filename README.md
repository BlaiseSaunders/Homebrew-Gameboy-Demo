# Early stage Gameboy Fighter Game



---

## File breakdown

### memory.asm
	- mem and vram set and cpy

### sprite.inc
	- Sprite accesors and macros


### main.asm
	- Intro point
	- Main code
	- Physics
	- Sprite movement

### ibmpc1.inc
	- Characters
	- Loaded into VRAM in main.asm

### standard-defs.inc
	- Standard gameboy defs
	- Cartridge info

### gbhw.inc
	- Gameboy address defines


---

## General notes

Variables set by assembler go in cartridge RAM
For HRAM, set the addresses yourself


---

# Please note this code is based off of the startup code from Whichta University's course
