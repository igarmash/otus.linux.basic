# устанавливаем wget
echo "Downloading wget..."
sudo yum install wget -y

# скачиваем и устанавливаем графану
echo "Downloadind and installing grafana..."
wget -q https://dl.grafana.com/oss/release/grafana-7.4.2-1.x86_64.rpm
sudo yum install ./grafana-7.4.2-1.x86_64.rpm -y

# скачиваем прометей
# источник: https://prometheus.io/download/
echo "Downloading prometheus..."
wget -q https://github.com/prometheus/prometheus/releases/download/v2.25.0/prometheus-2.25.0.linux-amd64.tar.gz

# скачиваем node_exporter
# источник: https://prometheus.io/download/
echo "Downloading node_exporter..."
wget -q https://github.com/prometheus/node_exporter/releases/download/v1.1.1/node_exporter-1.1.1.linux-amd64.tar.gz

# добавляем пользователя для prometheus, от которого будет запускаться сам сервис прометея
# /sbin/nologin чтобы под пользователем нельзся было зайти
echo "Creating user prometheus..."
sudo useradd --no-create-home --shell /sbin/nologin prometheus

# добавляем пользователя для node_exporter (/bin/false также ограничивает возможность логона указанного пользователя)
# пользователь node_exporter нужен для сбора информации и метрик
# /sbin/nologin == /bin/false
echo "Creaing user node_exporter..."
sudo useradd --no-create-home --shell /bin/false node_exporter

# создаем папки для хранения конфига и библиотек прометея
echo "Creating prometheus folders..."
mkdir /etc/prometheus
mkdir /var/lib/prometheus

# меняем владельца вышесозданных директорий на пользователя прометея
# (-R == recursive)
echo "Changing owner of the created prometheus folders..."
sudo chown -R prometheus: /etc/prometheus
sudo chown -R prometheus: /var/lib/prometheus

# распаковываем архив
echo "Extracting prometheus-2.25.0.linux-amd64.tar.gz"
sudo tar xfz prometheus-*.t*.gz

# распаковываем архив
echo "Extracting node_exporter-1.1.1.linux-amd64.tar.gz"
sudo tar xfz node_exporter-*.t*.gz

# копируем node_exporter в /usr/local/bin
echo "Copying node_exporter to /usr/local/bin"
sudo cp node_exporter-1.1.1.linux-amd64/node_exporter /usr/local/bin/

# меняем владельца node_exporter
echo "Changing owner of the /usr/local/bin/node_exporter"
sudo chown -v node_exporter /usr/local/bin/node_exporter

# создаём юнит для systemd для автозагрузки
echo "Copying node_exporter.service"
sudo cp node_exporter.service /etc/systemd/system/node_exporter.service

# копируем прометей
# -r рекурсивно, -v деталировано. -i интерактивно
# {console{_libraries,s},prometheus.yml} - перечисление
echo "Copying prometheus folders..."
sudo cp -rvi prometheus-2.25.0.linux-amd64/{console{_libraries,s},prometheus.yml} /etc/prometheus/
sudo cp prometheus-2.25.0.linux-amd64/prom{etheus,tool} /usr/local/bin

# меняем права директории prometheus
echo "Changing ownder of the created prometheus folders..."
sudo chown -v prometheus: /usr/local/bin/prom{etheus,tool}
sudo chown -R -v prometheus: /etc/prometheus/

# редактируем prometheus.yml
echo "Copying prometheus.yml..."
sudo cp /home/vagrant/prometheus.yml /etc/prometheus/prometheus.yml

# Создаем юнит для systemd
echo "Copying prometheus.service..."
sudo cp /home/vagrant/prometheus.service /etc/systemd/system/prometheus.service

# заставляем systemd перечитать имеющиейся таргеты и запускаем прометей
echo "Staring prometheus.service..."
sudo systemctl daemon-reload
sudo systemctl start prometheus.service
sudo systemctl status prometheus.service

# запускаем свежесозданный сервис
echo "Starting node_exporter.service..."
sudo systemctl daemon-reload
sudo systemctl start node_exporter.service
sudo systemctl status node_exporter.service

# запускаем графану
echo "Starting grafana-server..."
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl status grafana-server

# прописываем сервисы в автозагрузку
echo "Enabling services..."
sudo systemctl enable prometheus.service
sudo systemctl enable node_exporter.service
sudo systemctl enable grafana-server

echo "Provisioning finished."
echo "Please add dashboards 11074 and 1860 manually