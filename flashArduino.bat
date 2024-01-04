echo off

set arg1=%1

echo showping path
SET mypath=%~dp0

echo %arg1%

echo "BUILDING"
%mypath:~0,-1%\Arduino-cli\arduino-cli compile -b arduino:avr:uno %mypath:~0,-1%\arduinoProgram

echo "UPLOADING"
%mypath:~0,-1%\Arduino-cli\arduino-cli upload %mypath:~0,-1%\arduinoProgram -b arduino:avr:uno -p COM4

echo "UPLOADING COMPLETE!"

sleep 2

