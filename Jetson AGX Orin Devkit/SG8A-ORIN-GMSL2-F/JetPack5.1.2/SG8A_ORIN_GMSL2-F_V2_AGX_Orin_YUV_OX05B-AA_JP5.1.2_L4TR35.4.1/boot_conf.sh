#!/bin/bash

sudo sed -i '0,/root=\/dev\/[^ ]*/{s/root=\/dev\/[^ ]*/root=\/dev\/nvme0n1p1/}' /boot/extlinux/extlinux.conf