#!/bin/bash

folder=$(pwd)
processing-java --sketch=$folder --platform="windows" --export
mkdir application.windows64/images
mkdir application.linux64/images
mkdir application.windows64/arduinoProgram
mkdir application.linux64/arduinoProgram
rm -r application.windows64/source
rm -r application.linux64/source
cp arduinoProgram/functionBlocks.h application.windows64/arduinoProgram/
cp arduinoProgram/functionBlocks.h application.linux64/arduinoProgram/
cp -r images/* application.windows64/images/
cp -r images/* application.linux64/images/
touch application.windows64/program.csv
touch application.linux64/program.csv
echo "0" >> application.windows64/program.csv
echo "0" >> application.windows64/program.csv
echo "0" >> application.linux64/program.csv
echo "0" >> application.linux64/program.csv
7z.exe a FunctionBloX.zip ./application.windows64/*
7z.exe a FunctionBloX_linux.zip ./application.linux64/*
cp FunctionBloX.zip /c/Users/Gebruiker/Dropbox/FunctionBloX/
cp FunctionBloX_linux.zip /c/Users/Gebruiker/Dropbox/FunctionBloX/
rm -r application*