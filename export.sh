#!/bin/bash

#processing-java --sketch=\"c:\\Users\\sknippels\\Documents\\hobbyProjects\\functionBloX\\\" --build
processing-java --sketch="/c/Users/sknippels/Documents/hobbyProjects/functionBloX" --export
mkdir windows-amd64/images
mkdir windows-amd64/arduinoProgram
cp arduinoProgram/functionBlocks.h windows-amd64/arduinoProgram/
cp -r images/* windows-amd64/images/