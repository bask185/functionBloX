echo off

REM set ARDUINO_DIRECTORIES_DATA=%~dp0\Arduino-cli\configFiles
REM set ARDUINO_DIRECTORIES_USER=%~dp0\Arduino-cli\configFiles

Arduino-CLI\arduino-cli config init --overwrite
Arduino-CLI\arduino-cli core update-index
Arduino-CLI\arduino-cli core install arduino:avr
Arduino-CLI\arduino-cli lib install servo
pause

