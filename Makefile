CC = rgbasm
LINKER = rgblink
FIXER = rgbfix

CFLAGS =

LFLAGS  = 
DEPS = 
OBJ = main.o
ASM = main.asm
OUT_EXE = meme.gba 

all:$(OUT_EXE)

$(OBJ): $(ASM)
	$(CC) -o$(OBJ) main.asm

$(OUT_EXE): $(OBJ) 
	$(LINKER) -o$(OUT_EXE) $(OBJ)
	$(FIXER) $(OUT_EXE)

.PHONY:clean install rebuild
clean:
	rm -f *.o $(OUT_EXE)

install:
	cp ./$(OUT_EXE) /bin

rebuild: clean
	 make
