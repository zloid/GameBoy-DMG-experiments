@echo off

echo Assembling...
rgbasm -o src/boilerplate/index.o src/index.asm
echo Linking...
rgblink -o build/game.gb src/boilerplate/index.o
echo Fixing...
rgbfix -v -p 0 build/game.gb
rem rgbgfx -o out.2bpp in.png
rem rgbgfx -T -u -o out.2bpp in.png
echo Build complete.
