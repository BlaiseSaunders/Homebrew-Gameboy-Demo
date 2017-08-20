# Tryna make a GB game lol

Probs gonna be a fighter


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
	- Shit tonna characters
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

# Also I `borrowed` a tonne of this from Wichita Uni's course (found online)
# if I have to give it back will delet repo in heartbeat