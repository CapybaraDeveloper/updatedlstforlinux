#!/bin/bash

set -e

# 1. Проверка и установка git через rpm-ostree
if ! command -v git > /dev/null 2>&1; then
    echo "Git не найден. Устанавливаю через rpm-ostree..."
    sudo rpm-ostree install git
    echo "Установка завершена. Система Bazzite требует перезагрузки для активации git."
    echo "После перезагрузки запустите этот скрипт снова."
    exit 0
fi

# 2. Подготовка путей
# В Bazzite /opt доступен для записи, так как это ссылка на /var/opt
INSTALL_DIR="/opt/zapret.installer"
SUDO="sudo"

# Создаем папку если её нет (с правами sudo)
if [ ! -d "$INSTALL_DIR" ]; then
    $SUDO mkdir -p "$INSTALL_DIR"
    $SUDO chown $USER:$USER "$INSTALL_DIR"
fi

# 3. Клонирование или обновление репозитория
if [ ! -d "$INSTALL_DIR/.git" ]; then
    echo "Клонирование репозитория..."
    git clone github.com "$INSTALL_DIR"
else
    echo "Обновление репозитория..."
    cd "$INSTALL_DIR"
    if ! git pull; then
        echo "Ошибка обновления. Пересоздаем директорию..."
        cd /tmp
        $SUDO rm -rf "$INSTALL_DIR"
        $SUDO mkdir -p "$INSTALL_DIR"
        $SUDO chown $USER:$USER "$INSTALL_DIR"
        git clone github.com "$INSTALL_DIR"
    fi
fi

# 4. Запуск основного функционала
chmod +x "$INSTALL_DIR/zapret-control.sh"
echo "Запуск zapret-control..."
exec bash "$INSTALL_DIR/zapret-control.sh"
