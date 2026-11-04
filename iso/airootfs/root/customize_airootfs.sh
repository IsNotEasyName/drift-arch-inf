#!/usr/bin/env bash
set -e -u

# 1. Копируем конфиги в системную папку скелета (/etc/skel)
mkdir -p /etc/skel/.config
cp -r /root/configs/* /etc/skel/.config/ || true

# 2. Копируем обои в домашнюю папку пользователя
mkdir -p /etc/skel/.local/share/wallpapers
cp /root/wallpapers/*.jpg /etc/skel/.local/share/wallpapers/

# 3. Включаем NetworkManager, чтобы был интернет
systemctl enable NetworkManager.service
systemctl enable chwd-autoconfigure.service

# 4. Настраиваем автостарт графической оболочки (driftwm)
cat > /etc/skel/.zprofile << 'EOF'
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    # Запускаем случайные обои из папки (в фоне)
    WALLPAPER=$(find /etc/skel/.local/share/wallpapers -name "*.jpg" | shuf -n 1)
    swaybg -i "$WALLPAPER" &
    
    # Запускаем апплет Wi-Fi
    nm-applet --indicator &
    
    # Запускаем композитор
    exec driftwm
fi
EOF

# 5. Проверка наличия видеокарты NVIDIA и применение настроек
if lspci | grep -i 'nvidia' | grep -q -E "RTX [2-9][0-9]|GTX 16"; then
    echo "MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" > /etc/mkinitcpio.conf.d/nvidia.conf
    echo "options nvidia_drm modeset=1" > /etc/modprobe.d/nvidia.conf
    mkinitcpio -P
fi

# 6. Делаем скрипт исполняемым
chmod +x /root/customize_airootfs.sh
