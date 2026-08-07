#!/usr/bin/env bash
set -euo pipefail

CHIP="/sys/class/pwm/pwmchip5"
PWM="$CHIP/pwm0"

# Default frame rate: 30 Hz
FRAME_RATE=30

# Parse command line arguments
if [[ $# -gt 0 ]]; then
    case "$1" in
        -60|--60hz)
            FRAME_RATE=60
            echo "Using 60 Hz frame rate"
            ;;
        *)
            FRAME_RATE="$1"
            echo "Using frame rate: ${FRAME_RATE} Hz (Hertz)"
            ;;
    esac
else
    echo "No frame rate specified, using default: ${FRAME_RATE} Hz (Hertz)"
fi

# Validate frame rate is a positive number
if ! [[ "$FRAME_RATE" =~ ^[0-9]+$ ]] || [[ "$FRAME_RATE" -le 0 ]]; then
    echo "ERROR: Frame rate must be a positive integer (unit: Hz)" >&2
    echo "Usage: $0 [FRAME_RATE]" >&2
    echo "       $0 -60|--60hz  (for 60 Hz)" >&2
    echo "Examples:" >&2
    echo "  $0 15  (for 15 Hz)" >&2
    echo "  $0 30  (for 30 Hz)" >&2
    echo "  $0 60  (for 60 Hz)" >&2
    echo "  $0 -60 (for 60 Hz)" >&2
    exit 1
fi

# Calculate period from frame rate (period = 1 / frequency in seconds, converted to nanoseconds)
# period_ns = 1000000000 / frame_rate
PERIOD=$((1000000000 / FRAME_RATE))

# Calculate duty cycle (10% of period)
DUTY_CYCLE=$((PERIOD * 10 / 100))

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
	echo "Exporting PWM device..."
	write_sysfs 0 "$CHIP/export"
fi

# Verify PWM device exists
if [[ ! -d "$PWM" ]]; then
	echo "ERROR: Failed to export PWM device at $PWM" >&2
	exit 1
fi

# Configure PWM
# echo "========================================="
# echo "PWM Configuration Summary:"
# echo "  Frame Rate: $FRAME_RATE Hz (Hertz)"
# echo "  Period: ${PERIOD} ns (nanoseconds)"
# echo "  Duty Cycle: ${DUTY_CYCLE} ns (nanoseconds)"
# echo "  Duty Cycle Percentage: 10%"
# echo "========================================="
write_sysfs "$PERIOD" "$PWM/period"
write_sysfs "$DUTY_CYCLE" "$PWM/duty_cycle"
write_sysfs 1 "$PWM/enable"
echo "PWM configured successfully!"

