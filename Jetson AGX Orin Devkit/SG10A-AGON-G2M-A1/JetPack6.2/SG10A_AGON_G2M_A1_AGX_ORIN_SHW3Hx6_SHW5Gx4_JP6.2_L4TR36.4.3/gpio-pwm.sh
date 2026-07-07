#!/usr/bin/env bash
set -euo pipefail

CHIP="/sys/class/pwm/pwmchip5"
PWM="$CHIP/pwm0"

write_sysfs() {
	local value="$1"
	local path="$2"

	if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
		echo "$value" > "$path"
	else
		echo "$value" | sudo tee "$path" > /dev/null
	fi
}

if [[ ! -d "$CHIP" ]]; then
	echo "ERROR: $CHIP not found" >&2
	exit 1
fi

# Cache sudo credentials once (so you don't need an interactive 'sudo su')
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
	sudo -v
fi

# Export pwm0 if not already exported
if [[ ! -d "$PWM" ]]; then
	write_sysfs 0 "$CHIP/export"
fi

# Configure PWM
write_sysfs 33333333 "$PWM/period"
write_sysfs 3333333 "$PWM/duty_cycle"
write_sysfs 1 "$PWM/enable"
