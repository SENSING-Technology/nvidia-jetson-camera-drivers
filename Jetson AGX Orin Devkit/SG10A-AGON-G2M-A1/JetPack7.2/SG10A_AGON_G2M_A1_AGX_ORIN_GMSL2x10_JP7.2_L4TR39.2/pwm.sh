#!/bin/bash
set -euo pipefail

if (( EUID != 0 )); then
    echo "Run with sudo: sudo $0 [frequency_hz|stop]" >&2
    exit 1
fi
if (( $# > 1 )); then
    echo "Usage: sudo $0 [frequency_hz|stop]" >&2
    exit 1
fi

action=${1:-30}
if [[ $action != stop ]]; then
    if [[ ! $action =~ ^[0-9]{1,4}$ ]]; then
        echo "Frequency must be an integer from 1 to 1000 Hz." >&2
        exit 1
    fi
    frequency=$((10#$action))
    if (( frequency < 1 || frequency > 1000 )); then
        echo "Frequency must be an integer from 1 to 1000 Hz." >&2
        exit 1
    fi
fi

chips=()
for chip in /sys/class/pwm/pwmchip*; do
    device=$(readlink -f "$chip/device") || continue
    if [[ ${device##*/} == pwm-gpio ]]; then
        chips+=("$chip")
    fi
done
if (( ${#chips[@]} != 1 )); then
    echo "Expected one pwm-gpio provider; found ${#chips[@]}. Load pwm-gpios.ko first." >&2
    exit 1
fi
pwm=${chips[0]}/pwm0

if [[ $action == stop ]]; then
    if [[ -e $pwm/enable ]] && (( $(< "$pwm/period") > 0 )); then
        echo 0 > "$pwm/enable"
    fi
    echo "PWM stopped. The updated pwm-gpios.ko releases FSYNC to input mode."
    exit 0
fi

# Disconnect the external generator before enabling this shared FSYNC output.
if [[ ! -d $pwm ]]; then
    echo 0 > "${chips[0]}/export"
fi
if (( $(< "$pwm/period") > 0 )); then
    echo 0 > "$pwm/enable"
    echo 0 > "$pwm/duty_cycle"
fi
echo $((1000000000 / frequency)) > "$pwm/period"
echo 0 > "$pwm/duty_cycle"
echo normal > "$pwm/polarity"
echo $((1000000000 / frequency / 10)) > "$pwm/duty_cycle"
echo 1 > "$pwm/enable"
echo "PWM enabled: ${frequency} Hz, 10% duty, ${chips[0]}."

