#!/bin/sh
#Cut this code out and insert into your own code wherever you need to store a op Secret Reference value in a script run from WSL.
#This requires the second PowerShell file to run first.

# Path to the PowerShell script requires the directory path to have double slahses for escaping syntax in bash
powershell_script="C:\\Windows\\Path\\To\\Your\\PS\\Script\\ps-op-set.ps1"

# Run the PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "$powershell_script"

# Read the contents of the temp.txt and pass it into a variable named my_variable
op_secret=$(<temp.txt)

#clean secret txt file from directory when done
rm temp.txt
