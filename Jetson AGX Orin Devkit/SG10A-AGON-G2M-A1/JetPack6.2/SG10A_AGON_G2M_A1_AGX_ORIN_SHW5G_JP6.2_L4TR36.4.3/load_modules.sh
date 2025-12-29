#!/bin/bash

sudo busybox devmem 0x02448020 w 0x1008

sudo insmod ko/shw5g.ko
