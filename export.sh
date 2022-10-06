#!/bin/bash

folder=$(pwd)
processing-java --sketch=$folder --export
mkdir windows-amd64/images
mkdir windows-amd64/arduinoProgram
rm -r windows-amd64/source
cp arduinoProgram/functionBlocks.h windows-amd64/arduinoProgram/
cp -r images/* windows-amd64/images/
touch windows-amd64/program.csv
echo "0" >> windows-amd64/program.csv
echo "0" >> windows-amd64/program.csv
7z.exe a binary.zip ./windows-amd64/*
rm -r windows-amd64