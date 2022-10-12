#!/usr/bin/env python

import os

from datetime import datetime

def getVersion():
    versionNumber = ""
    versionNumber = input("Which version will you be releasing?\n")
    print("VERSION " + versionNumber + " SELECTED\n" )
    return versionNumber



def getCommitText() :
    commitMessage = ""
    print("Enter a description for the changelog, send 'done' when ready")
    dateTimeObj = datetime.now()

        #with open("changelog.txt", "w") as changelog: 
            #changelog.write( versionNumber + "   Date/time:" + str(dateTimeObj) + "\n" )
    newLine = ""
    while( newLine != 'done'):
        newLine = input()
        if( newLine != 'done' ):
            commitMessage += newLine + "\n"

    with open("temp.txt", "a") as temp: 
        temp.write(commitMessage)
        temp.close()

def updateVersionNumber():
    with open("functionBlox.pde", "r") as file:
        lines = file.readlines()
        lines = lines[:-1]
        file.close()

    with open("functionBlox.pde", "w") as file: 
        for line in lines:
            file.write( line )
        file.write('void printVersion() { text("'+versionNumber+'", width/2, height - 2*gridSize) ; }')
        file.close()



def buildProject():
    os.system("folder=$(pwd);processing-java --sketch=$folder --build")            # Build project, before commiting and releasing
    os.system("./export.sh")

def commit():
    answer = input("Do you wish to perform a git commit?[y/n] (recommended for version.h)\n")
    if answer == 'y' or answer == 'Y':
        os.system('git commit -a -F "temp.txt"')
        print("COMMIT MADE\n")
    else:
        print("NO COMMIT MADE\n")
    os.system('rm temp.txt')



def tag():
    print("MAKING GIT TAG " + versionNumber)
    os.system("git tag " + versionNumber )

def changelog():
    answer = input("Do you wish to update changelog.txt? [y/n]\n")
    if answer == 'y' or answer == 'Y':
        os.system("git log --no-walk --tags --decorate=short | grep -v ^Author:  > changelog.txt")
        os.system("git add changelog.txt")                                          # just in case
        print("CHANGELOG.TXT UPDATED")
    else:
        print( "CHANGELOG.TXT NOT UPDATED")



def push():
    answer = input("Do you wish to push to git server?[y/n] \n")
    if answer == 'y' or answer == 'Y':
        os.system('git push')
        print("REPOSITORY PUSHED\n")
    else:
        print("REPOSITORY NOT PUSHED\n")

################# MAIN PROGRAM #################
versionNumber = getVersion()
getCommitText()
updateVersionNumber()
buildProject()
commit()
tag()
changelog()
push()

print("\nNEW VERSION SUCCUSFULLY RELEASED!")


### TODO ###

# alter run method by export
# replace version.h by appending version to bottom of file
#   READ ENTIRE FILE AND SEARCH FOR versionNumber 
#


