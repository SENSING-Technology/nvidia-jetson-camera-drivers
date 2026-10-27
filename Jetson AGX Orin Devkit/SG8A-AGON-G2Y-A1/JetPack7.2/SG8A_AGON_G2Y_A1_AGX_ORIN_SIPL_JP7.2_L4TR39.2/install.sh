#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
mode=${1:---install}
case "$mode" in --check|--install) ;; *) echo 'Usage: ./install.sh [--check|--install]' >&2; exit 2;; esac
# Match the reference package: ./install.sh installs, elevating as needed.
if [[ $mode == --install ]] && (( EUID != 0 )); then
    exec sudo -- bash "$root/install.sh" --install
fi
errors=0
fail() { echo "ERROR: $*" >&2; errors=$((errors + 1)); }
[[ $(uname -m) == aarch64 ]] || fail 'Run on the target aarch64 Jetson.'
if [[ -r /proc/device-tree/compatible ]]; then
    tr '\0' '\n' < /proc/device-tree/compatible | grep -q 'nvidia,p3701\|nvidia,p3737.*p3701' || fail 'Target is not an AGX Orin devkit.'
else fail 'Device-tree compatible is unavailable.'; fi
if [[ -r /etc/nv_tegra_release ]]; then
    grep -Eq '^# R39 .*REVISION: 2\.0([, ]|$)' /etc/nv_tegra_release || fail 'This package targets L4T 39.2.0; do not mix 39.2.1 binaries.'
else fail 'Missing /etc/nv_tegra_release.'; fi
[[ -s "$root/dts/tegra234-camera-sipl-camera-overlay.dtbo" ]] || fail 'Build the overlay first.'
for name in max96712 s56 s56c s36 shw3g shw5g sg3_ox03h10c_g2f sg8_ox08dc_gmsl2 sgx_yuv_gmsl2 tegra_deser_power; do
    case "$name" in max96712|tegra_deser_power) lib="libnvuddf_${name}_library.so";; *) lib="libnvuddf_${name}_cameramodule_library.so";; esac
    [[ -s "$root/driver/$lib" ]] || fail "Missing rebuilt driver/$lib"
done
[[ -s "$root/driver/libnvsipl_qry_vb1940.so" ]] || fail 'Missing driver/libnvsipl_qry_vb1940.so'
[[ -s "$root/driver/libnvcamerahal.so" ]] || fail 'Missing YUV-capable driver/libnvcamerahal.so'
for name in nvsipl_camera nvsipl_query; do
    [[ -x "$root/$name" ]] || fail "Missing rebuilt $name"
done
if (( errors > 0 )); then exit 1; fi
for artifact in "$root"/driver/*.so "$root/nvsipl_camera" "$root/nvsipl_query"; do
    if ! deps=$(ldd "$artifact" 2>&1); then fail "Cannot inspect dependencies: $artifact";
    elif [[ $deps == *'not found'* ]]; then fail "Missing dependencies for $artifact: $deps"; fi
done
(( errors == 0 )) || exit 1
printf '%s\n' 'Environment checks passed.'
[[ $mode == --install ]] || exit 0
backup=$(mktemp -d /var/backups/sg8a-sipl-39.2.XXXXXXXX)
# Preserve each existing file before replacing it; leave unrelated drivers intact.
deploy() {
    local src=$1 dst=$2 perm=$3
    if [[ -e $dst || -L $dst ]]; then
        mkdir -p -- "$backup$(dirname -- "$dst")"
        cp -a -- "$dst" "$backup$dst"
    fi
    install -D -m "$perm" -- "$src" "$dst"
}
for artifact in "$root"/driver/libnvuddf*.so; do deploy "$artifact" "/usr/lib/nvsipl_drv/${artifact##*/}" 644; done
deploy "$root/driver/libnvsipl_qry_vb1940.so" /usr/lib/nvsipl_drv/libnvsipl_qry_vb1940.so 644
deploy "$root/driver/libnvcamerahal.so" /usr/lib/aarch64-linux-gnu/nvidia/libnvcamerahal.so 644
for name in nvsipl_camera nvsipl_query; do deploy "$root/$name" "/usr/sbin/$name" 755; done
for artifact in "$root"/nito/*.nito; do deploy "$artifact" "/var/nvidia/nvcam/settings/sipl/${artifact##*/}" 644; done
deploy "$root/dts/tegra234-camera-sipl-camera-overlay.dtbo" /boot/tegra234-camera-sipl-camera-overlay.dtbo 644
printf 'Installed. Backup: %s\nSelect the overlay with jetson-io and reboot manually.\n' "$backup"
