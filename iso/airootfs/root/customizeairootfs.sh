# Проверка наличия видеокарты NVIDIA и применение настроек
if lspci | grep -i 'nvidia' | grep -q -E "RTX [2-9][0-9]|GTX 16"; then
    echo "NVIDIA GPU detected. Applying Wayland optimizations..."
    # Убедимся, что модули загружаются рано
    echo "MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" > /etc/mkinitcpio.conf.d/nvidia.conf
    # Включаем modeset
    echo "options nvidia_drm modeset=1" > /etc/modprobe.d/nvidia.conf
    # Пересобираем initramfs внутри собираемой системы
    mkinitcpio -P
fi
