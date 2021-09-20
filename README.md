# MatlabFortran

This repository shows an easy way to import data from Matlab to Fortran and back. Writing and reading large arrays can take quite some time: to maximize speed, it is best to use the binary format. Reading and writing binary files from/to disk is much faster than txt format.

**HOW TO USE IT**

I tested the code with the Intel Fortran compiler on a Windows machine. In order to compile the Fortran code and create an executable, type the following:

`ifort /check:bounds main_fortran.f90 -o run.exe  `

This generates a Windows executable called run.exe. In order to maximize speed, the code can be compiled with the alternative line:

`ifort /fast main_fortran.f90 -o run.exe  `

This however will not catch some errors.

Once the executable has been generated, place it in the same folder where the Matlab files are located. Then run the Matlab file testIO.m

