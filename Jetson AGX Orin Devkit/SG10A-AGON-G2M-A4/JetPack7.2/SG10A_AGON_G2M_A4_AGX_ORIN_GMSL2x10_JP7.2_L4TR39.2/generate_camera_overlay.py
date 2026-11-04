#!/usr/bin/env python3

import os
import sys
import re

# Configuration
# Monocular cameras
MONOCULAR_MODELS = ["shw3g", "sgx-yuv-gmsl2", "shw5g"]
# Stereo cameras (used in pairs)
STEREO_MODELS = ["s56c"]
# Combined list for selection
ALL_MODELS = MONOCULAR_MODELS + STEREO_MODELS

# Map camera model to image format
SENSOR_FORMAT_MAP = {
    "shw3g": "raw12",
    "sgx-yuv-gmsl2": "uyvy",
    "shw5g": "raw10",
    "s56c": "raw10",
}

MODEL_TO_DTS_FILE = {
    "shw3g": "dts/tegra234-camera-shw3g-gmsl2x10-overlay.dts",
    "sgx-yuv-gmsl2": "dts/tegra234-camera-yuv-gmsl2x10-overlay.dts",
    "shw5g": "dts/tegra234-camera-shw5g-gmsl2x10-overlay.dts",
     "s56c": "dts/tegra234-camera-s56c-gmsl2x5-overlay.dts",
}

TPL_FILE, OUT_DTS, OUT_DTBO = (
    "dts/tegra234-camera-sgcam-template-overlay.dts",
    "dts/tegra234-camera-sgcamx10-overlay.dts",
    "dts/tegra234-camera-sgcamx10-overlay.dtbo",
)

def extract_node(dts_content, target_node):
    """从DTS内容中提取指定节点及其完整内容"""
    start_pos = dts_content.find(f"{target_node} {{")
    if start_pos == -1:
        return None
    level, i = 0, start_pos + len(target_node) + 1
    while i < len(dts_content):
        if dts_content[i] == '{':
            level += 1
        elif dts_content[i] == '}':
            level -= 1
        if level == 0:
            return dts_content[start_pos:i+1].strip()
        i += 1
    return None

def parse_sensor_model(node_content):
    """解析节点内容中的 sensor_model 属性"""
    match = re.search(r'sensor_model\s*=\s*"([^"]+)"', node_content, re.DOTALL)
    return match.group(1) if match else "Unknown"

def get_node_info(port_idx):
    """根据端口索引计算节点名(带下划线)与地址"""
    if port_idx < 8:
        addr = 0x1b if port_idx % 2 == 0 else 0x1c
    else:
        addr = 0x1d if port_idx % 2 == 0 else 0x1e
    node_name = f"cam_{port_idx}@{addr:02x}"   # 关键修复：保留下划线
    return node_name, addr

def main():
    print("Available models:")
    for i, m in enumerate(ALL_MODELS):
        fmt = SENSOR_FORMAT_MAP.get(m, "unknown")
        print(f"  {i}: {m} ({fmt})")
    print()

    cameras = [None] * 10
    i = 0
    while i < 10:
        if cameras[i] is not None:
            i += 1
            continue
        while True:
            try:
                sel = int(input(f"Select camera for cam_{i} (0-{len(ALL_MODELS)-1}): "))
                if 0 <= sel < len(ALL_MODELS):
                    model = ALL_MODELS[sel]
                    if model in STEREO_MODELS:
                        if i % 2 != 0 or i == 9 or cameras[i + 1] is not None:
                            print(f"Error: Stereo camera '{model}' needs an even port (0,2,4,6,8).")
                            continue
                        cameras[i] = model
                        cameras[i + 1] = model
                        print(f"  Placed stereo pair '{model}' on cam_{i} and cam_{i+1}.")
                        i += 2
                        break
                    else:
                        cameras[i] = model
                        i += 1
                        break
                else:
                    print("Invalid number. Try again.")
            except ValueError:
                print("Please enter a valid number.")

    print("\nSelected configurations:")
    for idx, model in enumerate(cameras):
        node_name, _ = get_node_info(idx)
        print(f"  {node_name} -> {model}")
    print()

    replacements = {}
    for i, model in enumerate(cameras):
        node_name, _ = get_node_info(i)
        with open(MODEL_TO_DTS_FILE[model], 'r') as f:
            source_dts = f.read()
        node_content = extract_node(source_dts, node_name)
        if node_content:
            replacements[node_name] = node_content
            print(f"  Found {node_name}")
        else:
            print(f"  Warning: {node_name} not found in {MODEL_TO_DTS_FILE[model]}", file=sys.stderr)

    with open(TPL_FILE, 'r') as f:
        content = f.read()
    for old_node, new_def in replacements.items():
        start_pos = content.find(f"{old_node} {{")
        if start_pos == -1:
            continue
        level, i = 0, start_pos + len(old_node) + 1
        while i < len(content):
            if content[i] == '{':
                level += 1
            elif content[i] == '}':
                level -= 1
            if level == 0:
                content = content[:start_pos] + new_def + content[i+1:]
                break
            i += 1
        
 
    with open(OUT_DTS, 'w') as f:
        f.write(content)
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
    for port_idx in range(10):
        node_name, _ = get_node_info(port_idx)
        node_content = extract_node(content, node_name)
        sensor_model = parse_sensor_model(node_content) if node_content else "EMPTY"
        fmt = SENSOR_FORMAT_MAP.get(sensor_model, "unknown")
        print(f"Port {port_idx} ({node_name}): {sensor_model} ({fmt})")
    print("--- End of Configuration ---\n")

if __name__ == "__main__":
    main()