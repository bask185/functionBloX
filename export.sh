#!/bin/bash

folder=$(pwd)
processing-java --sketch=$folder --variant="windows" --export
mkdir windows-amd64/images
mkdir windows-amd64/Arduino-cli
# mkdir application.linux64/images

mkdir windows-amd64/arduinoProgram
mkdir windows-amd64/examples
mkdir windows-amd64/sketchBook
# mkdir application.linux64/arduinoProgram

rm -r windows-amd64/source
# rm -r application.linux64/source

# for windows we need to deploy these batch files along side the arduino-cli folder
# cp flashArduino.bat windows-amd64/  OBSOLETE in favor of direct calls to Arduino-CLI
cp installArduinoCLI.bat windows-amd64/
cp -r Arduino-cli/* windows-amd64/Arduino-cli/

cp arduinoProgram/functionBlocks.h windows-amd64/arduinoProgram/
# cp arduinoProgram/functionBlocks.h application.linux64/arduinoProgram/

cp arduinoProgram/NmraDcc.h windows-amd64/arduinoProgram/
# cp arduinoProgram/NmraDcc.h application.linux64/arduinoProgram/
cp arduinoProgram/NmraDcc.cpp windows-amd64/arduinoProgram/
# cp arduinoProgram/NmraDcc.cpp application.linux64/arduinoProgram/

cp -r images/* windows-amd64/images/
# cp -r images/* application.linux64/images/


cp -r changelog.txt windows-amd64/images/
# cp -r changelog.txt application.linux64/images/

cp -r sketchBook/* windows-amd64/sketchBook/
cp -r examples/* windows-amd64/examples/
# cp -r sketchBook/* application.linux64/

touch windows-amd64/program.csv
# touch application.linux64/program.csv

echo "0" >> windows-amd64/program.csv
echo "0" >> windows-amd64/program.csv
# echo "0" >> application.linux64/program.csv
# echo "0" >> application.linux64/program.csv

# 7z.exe a FunctionBloX.zip ./windows-amd64/*
# 7z.exe a FunctionBloX_linux.zip ./application.linux64/*

# mv FunctionBloX.zip /c/Users/Gebruiker/Dropbox/FunctionBloX/
# mv FunctionBloX_linux.zip /c/Users/Gebruiker/Dropbox/FunctionBloX/

#rm -r application*