#!/bin/csh

source ~/USER/cshrc

xrun -access +rwc -uvm -f file.f +SVSEED=random -define INJECT_ERROR #-gui 