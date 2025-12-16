Обновляет систему и ставит необходимые утилиты.
Скачивает последнюю стабильную версию Prometheus, создаёт пользователя, настраивает каталоги и systemd‑службу.
Добавляет официальный репозиторий Grafana, устанавливает пакет и запускает сервис.
ufw открывает порты (9090 — Prometheus, 3000 — Grafana).

wget https://raw.githubusercontent.com/astrelkovsys/install_prometheus_grafana/master/install_prometheus_grafana.sh

chmod +x install_prometheus_grafana.sh
sudo ./install_prometheus_grafana.sh
