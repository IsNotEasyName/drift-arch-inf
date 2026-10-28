#!/usr/bin/env bash
set -e -u

# 1. Копируем конфиги в системную папку скелета (/etc/skel)
# Все новые пользователи автоматически получат эти настройки
mkdir -p /etc/skel/.config
cp -r /root/configs/* /etc/skel/.config/ || true

# 2. Включаем NetworkManager, чтобы был интернет
systemctl enable NetworkManager.service

# 3. Настраиваем автостарт графической оболочки (driftwm)
# Создаем файл .zprofile для автозапуска при входе в терминал (tty1)
cat > /etc/skel/.zprofile << 'EOF'
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec driftwm
fi
EOF

# Устанавливаем ghostty как терминал по умолчанию для driftwm
echo 'export TERMINAL=ghostty' >> /etc/skel/.zprofile

# 4. Делаем скрипт исполняемым (чтобы система могла его запустить)
chmod +x /root/customize_airootfs.sh

# Копируем локальный репозиторий внутрь системы
cp -r /root/local_repo /etc/pacman.d/

systemctl enable chwd-autoconfigure.service

echo 'exec nm-applet --indicator &' >> /etc/skel/.zprofile
