#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------
# 1. Обновление пакетов и установка зависимостей
# -------------------------------------------------
sudo apt update
sudo apt install -y wget tar gnupg2 software-properties-common

# -------------------------------------------------
# 2. Установка Prometheus
# -------------------------------------------------
PROM_VERSION="2.53.0"                     # актуальная версия на момент написания
PROM_URL="https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz"

# Скачивание и распаковка
wget -qO- "$PROM_URL" | sudo tar -xz -C /opt
sudo mv /opt/prometheus-${PROM_VERSION}.linux-amd64 /opt/prometheus

# Создание пользователя и группы
sudo useradd --no-create-home --shell /usr/sbin/nologin prometheus

# Настройка каталогов
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo cp /opt/prometheus/prometheus.yml /etc/prometheus/
sudo cp -r /opt/prometheus/consoles /opt/prometheus/console_libraries /etc/prometheus/
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus /opt/prometheus

# Systemd‑служба
cat <<'EOF' | sudo tee /etc/systemd/system/prometheus.service > /dev/null
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/opt/prometheus/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Запуск и включение
sudo systemctl daemon-reload
sudo systemctl enable --now prometheus

# -------------------------------------------------
# 3. Установка Grafana
# -------------------------------------------------
# Добавляем репозиторий Grafana
sudo apt install -y apt-transport-https
wget -qO- https://apt.grafana.com/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/grafana.gpg
echo "deb [signed-by=/usr/share/keyrings/grafana.gpg] https://apt.grafana.com stable main" | \
  sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt update
sudo apt install -y grafana

# Включаем и стартуем сервис
sudo systemctl enable --now grafana-server

# -------------------------------------------------
# 4. Открытие портов в firewall (если используется ufw)
# -------------------------------------------------
if command -v ufw >/dev/null; then
    sudo ufw allow 9090/tcp   # Prometheus
    sudo ufw allow 3000/tcp   # Grafana
fi

# -------------------------------------------------
# 5. Проверка статуса
# -------------------------------------------------
echo "=== Установка завершена ==="
echo "Prometheus доступен по http://<your_ip>:9090"
echo "Grafana доступна по http://<your_ip>:3000 (логин: admin, пароль: admin)"
