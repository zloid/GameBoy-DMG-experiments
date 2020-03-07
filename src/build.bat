@echo off

echo Assembling...
rgbasm -o ../build/public_build.o index.asm
echo Linking...
rgblink -o ../build/game.gb ../build/public_build.o
echo Fixing...
rgbfix -v -p 0 ../build/game.gb
rem rgbgfx -o out.2bpp in.png
rem rgbgfx -T -u -o out.2bpp in.png
echo Build complete.