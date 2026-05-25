#!/bin/bash

# 1. 清屏
clear

# 配置文件路径
CONF_FILE="/boot/extlinux/extlinux.conf"
BACKUP_FILE="${CONF_FILE}.bak"

# 检查备份文件是否存在（因为我们要用它来覆盖）
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    echo "Please ensure $BACKUP_FILE exists as the clean original file."
    exit 1
fi

# 2. 显示菜单
echo "=========================================="
echo "   Jetson Camera Configuration Selector"
echo "=========================================="
echo "Please select the camera to enable:"
echo "  0 : SG8-OX08DC-5300-G2G-Hxxx"
echo "  1 : SG8-IMX728C-G2G-Hxxx"
echo "  2 : YUV-Camera"
echo "=========================================="
read -p "Enter number [0-2]: " choice

# 3. 根据选择设置变量
case $choice in
    0)
        OVERLAY_FILE="tegra264-camera-ox08dx8-overlay.dtbo"
        ;;
    1)
        OVERLAY_FILE="tegra264-camera-imx728x8-overlay.dtbo"
        ;;
    2)
        OVERLAY_FILE="tegra264-camera-yuv-gmsl2x8-overlay.dtbo"
        ;;
    *)
        echo "Invalid selection. Exiting."
        exit 1
        ;;
esac

echo ""
echo "Target Configuration: $OVERLAY_FILE"

# 4. 核心操作：强制重置 + 新增

# 步骤 A: 强制覆盖当前文件（回到初始状态）
sudo cp "$BACKUP_FILE" "$CONF_FILE"
echo "System reset to default state using backup..."

# 步骤 B: 在第一个 "INITRD /boot/initrd" 后插入两行
# 使用 awk 确保只在第一次匹配时插入，且兼容性好
awk -v overlay="$OVERLAY_FILE" '
/INITRD \/boot\/initrd/ && inserted==0 {
    print $0
    print "      FDT /boot/dtb/kernel_tegra264-p4071-0000+p3834-0008-nv.dtb"
    print "      OVERLAYS /boot/" overlay
    inserted=1
    next
}
{ print $0 }
' "$CONF_FILE" > "${CONF_FILE}.tmp" && mv "${CONF_FILE}.tmp" "$CONF_FILE"

echo "New configuration added successfully."

# # 5. 显示预览
# echo ""
# echo "Current Configuration Preview:"
# echo "----------------------------------------"
# # 使用 sed 只打印 LABEL primary 到下一个 LABEL 之间的内容
# sed -n '/LABEL primary/,/^LABEL /{ /^LABEL /d; p }' "$CONF_FILE"
# echo "----------------------------------------"

echo ""
echo "Done. Please reboot the system to apply changes: sudo reboot"