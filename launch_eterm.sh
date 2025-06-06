#!/bin/bash

WINEPREFIX="$HOME/.wine"
EXE_PATH="e61_6809.exe"  # или полный путь, если он в другом месте

# 1. Назначаем COM1 на нужный порт
sudo rm -f /dev/ttyS0
sudo ln -s /dev/ttyUSB0 /dev/ttyS0

# 2. Открываем доступ к USB-порту
sudo chmod 666 /dev/ttyUSB0

# 3. Запускаем программу
WINEPREFIX="$WINEPREFIX" wine "$EXE_PATH"
