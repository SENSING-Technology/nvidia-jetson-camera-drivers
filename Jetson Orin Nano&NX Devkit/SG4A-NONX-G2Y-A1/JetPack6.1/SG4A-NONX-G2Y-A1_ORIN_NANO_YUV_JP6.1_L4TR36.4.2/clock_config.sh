#!/bin/bash

echo 1 > /sys/kernel/debug/bpmp/debug/clk/nvcsi/mrq_rate_locked
echo 214300000 > /sys/kernel/debug/bpmp/debug/clk/nvcsi/rate
