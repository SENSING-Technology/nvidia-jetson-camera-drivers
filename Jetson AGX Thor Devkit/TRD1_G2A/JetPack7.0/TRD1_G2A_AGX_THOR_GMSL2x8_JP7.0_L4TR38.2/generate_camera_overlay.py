#!/usr/bin/env python3

import os
import sys

# Configuration
# Monocular cameras
MONOCULAR_MODELS = ["ox08d", "shw3g", "shw5g", "sgx-yuv-gmsl2"]
# Stereo cameras (used in pairs)
STEREO_MODELS = ["s36", "s56", "sdv11nm1"]
# Combined list for selection
ALL_MODELS = MONOCULAR_MODELS + STEREO_MODELS

# Map camera model to image format
SENSOR_FORMAT_MAP = {
    "ox08d": "raw12",
    "shw3g": "raw12",
    "shw5g": "raw10",
    "sgx-yuv-gmsl2": "uyvy",
    "s36": "uyvy",
    "s56": "raw10",
    "sdv11nm1": "raw10"
}

MODEL_TO_DTS_FILE = {
    "ox08d": "dts/tegra264-camera-sgcam-ox08dx8-overlay.dts",
    "s36": "dts/tegra264-camera-sgcam-s36x4-overlay.dts",
    "s56": "dts/tegra264-camera-sgcam-s56x4-overlay.dts",
    "sdv11nm1": "dts/tegra264-camera-sgcam-sdv11nm1x4-overlay.dts",
    "shw3g": "dts/tegra264-camera-sgcam-shw3gx8-overlay.dts",
    "shw5g": "dts/tegra264-camera-sgcam-shw5gx8-overlay.dts",
    "sgx-yuv-gmsl2": "dts/tegra264-camera-sgcam-yuv-gmsl2x8-overlay.dts",
}

TPL_FILE, OUT_DTS, OUT_DTBO = "dts/tegra264-camera-sgcam-template-overlay.dts", "dts/tegra264-camera-sgcamx8-overlay.dts", "dts/tegra264-camera-sgcamx8-overlay.dtbo"

def extract_node(dts_content, target_node):
    start_pos = dts_content.find(f"{target_node} {{")
    if start_pos == -1: return None
    level, i = 0, start_pos + len(target_node) + 1
    while i < len(dts_content):
        if dts_content[i] == '{': level += 1
        elif dts_content[i] == '}': level -= 1
        if level == 0: return dts_content[start_pos:i+1].strip()
        i += 1
    return None

def parse_sensor_model(node_content):
    match = re.search(r'sensor_model\s*=\s*"([^"]+)"', node_content, re.DOTALL)
    return match.group(1) if match else "Unknown"

def main():
    print("Available models:")
    for i, m in enumerate(ALL_MODELS): 
        fmt = SENSOR_FORMAT_MAP.get(m, "unknown")
        print(f"  {i}: {m} ({fmt})")
    print()

    cameras = [None] * 8
    i = 0
    while i < 8:
        if cameras[i] is not None: i += 1; continue
        while True:
            try:
                sel = int(input(f"Select camera for cam_{i} (0-{len(ALL_MODELS)-1}): "))
                if 0 <= sel < len(ALL_MODELS):
                    model = ALL_MODELS[sel]
                    if model in STEREO_MODELS:
                        # Check if port is even and next port is free for stereo pair
                        if i % 2 != 0 or i == 7 or cameras[i + 1] is not None:
                            print(f"Error: Stereo camera '{model}' needs an even port (0,2,4,6).")
                            continue
                        cameras[i] = model; cameras[i + 1] = model; print(f"  Placed stereo pair '{model}' on cam_{i} and cam_{i+1}."); i += 2; break
                    else: # Monocular camera
                        cameras[i] = model; i += 1; break
                else: print("Invalid number. Try again.")
            except ValueError: print("Please enter a valid number.")

    print("\nSelected configurations:")
    for idx, model in enumerate(cameras): print(f"  cam_{idx} -> {model}")
    print()

    replacements = {}
    for i, model in enumerate(cameras):
        addr = (i + 32) if i < 4 else ((i - 4) + 32)
        node_name = f"cam_{i}@{addr:02x}"
        with open(MODEL_TO_DTS_FILE[model], 'r') as f: source_dts = f.read()
        node_content = extract_node(source_dts, node_name)
        if node_content: 
            replacements[node_name] = node_content
            print(f"  Found {node_name}")
        else: 
            print(f"  Warning: {node_name} not found in {MODEL_TO_DTS_FILE[model]}", file=sys.stderr)

    with open(TPL_FILE, 'r') as f: content = f.read()
    for old_node, new_def in replacements.items():
        start_pos = content.find(f"{old_node} {{")
        if start_pos == -1: continue
        level, i = 0, start_pos + len(old_node) + 1
        while i < len(content):
            if content[i] == '{': level += 1
            elif content[i] == '}': level -= 1
            if level == 0: 
                content = content[:start_pos] + new_def + content[i+1:]
                break
            i += 1

    with open(OUT_DTS, 'w') as f: f.write(content)
    print(f"\nGenerated: {OUT_DTS}")

    if os.system("which cpp dtc > /dev/null 2>&1") != 0:
        print("Error: 'cpp' or 'dtc' not found.", file=sys.stderr)
        return

    print("Compiling...")
    if os.system(f"cpp -nostdinc -I ./dts/include -undef -x assembler-with-cpp {OUT_DTS} | dtc -@ -I dts -O dtb -o {OUT_DTBO}") != 0:
        print(f"Error compiling DTBO. Check {OUT_DTS}.", file=sys.stderr)
        return

    print(f"Generated: {OUT_DTBO}")
    print("\n--- Final Port Configuration ---")
    for port_idx in range(8):
        addr = (port_idx + 32) if port_idx < 4 else ((port_idx - 4) + 32)
        full_node_name = f"cam_{port_idx}@{addr:02x}"
        node_content = extract_node(content, full_node_name)
        sensor_model = parse_sensor_model(node_content) if node_content else "EMPTY"
        # Look up format based on the sensor model found in the node
        fmt = SENSOR_FORMAT_MAP.get(sensor_model, "unknown")
        print(f"Port {port_idx} (cam_{port_idx}): {sensor_model} ({fmt})")
    print("--- End of Configuration ---\n")

if __name__ == "__main__":
    import re # Import re here as it's used inside main
    main()