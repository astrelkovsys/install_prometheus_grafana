#!/bin/bash

# Обновление пакетов
sudo apt update && sudo apt upgrade -y
sudo apt install -y wget software-properties-common apt-transport-https gnupg2

# Установка и настройка Prometheus
echo "Установка Prometheus..."

# Получение последней версии Prometheus
PROMETHEUS_VERSION=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
wget https://github.com/prometheus/prometheus/releases/download/${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
tar xvf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
cd prometheus-${PROMETHEUS_VERSION}.linux-amd64/

# Перемещение файлов
sudo mv prometheus /usr/local/bin/
sudo mv promtool /usr/local/bin/
sudo mv consoles /etc/prometheus/
sudo mv console_libraries /etc/prometheus/

# Создание конфигурационного файла
sudo bash -c 'cat <<EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
EOF'

# Создание системного юнита для Prometheus
sudo bash -c 'cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Service
After=network.target

[Service]
User=root
Group=root
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml

[Install]
WantedBy=multi-user.target
EOF'

# Запуск Prometheus
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus

# Установка и настройка Grafana
echo "Установка Grafana..."

# Добавление ключа репозитория Grafana
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/release/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# Установка Grafana
sudo apt update
sudo apt install -y grafana

# Запуск Grafana
sudo systemctl start grafana
sudo systemctl enable grafana

# Вывод информации
echo "Prometheus доступен по адресу http://localhost:9090"
echo "Grafana доступна по адресу http://localhost:3000"
echo "Пользователь по умолчанию: admin, пароль: admin"
