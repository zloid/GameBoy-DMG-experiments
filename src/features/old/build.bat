@echo off

echo Assembling...
rgbasm -o main.o main.asm
echo Linking...
rgblink -o helloW3.gb main.o
echo Fixing...
rgbfix -v -p 0 helloW3.gb
rem rgbgfx -o out.2bpp in.png
rem rgbgfx -T -u -o out.2bpp in.png
echo Build complete.
