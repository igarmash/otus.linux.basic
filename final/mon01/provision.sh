#!/bin/bash
echo "Hostname: $(hostname)"

echo "Adding centos7 epel repository..."
sudo yum install -y epel-release

echo "Installing wget..."
sudo yum install -y wget

echo "Installing grafana..."
sudo yum install ./grafana-7.4.2-1.x86_64.rpm -y

echo "Creaing user node_exporter..."
sudo useradd --no-create-home --shell /bin/false node_exporter

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

echo "Starting node_exporter.service..."
sudo systemctl daemon-reload
sudo systemctl start node_exporter.service
sudo systemctl status node_exporter.service

echo "Creating user prometheus..."
sudo useradd --no-create-home --shell /sbin/nologin prometheus

echo "Creating prometheus folders..."
mkdir /etc/prometheus
mkdir /var/lib/prometheus

echo "Changing owner of the created prometheus folders..."
sudo chown -R prometheus: /etc/prometheus
sudo chown -R prometheus: /var/lib/prometheus

echo "Extracting prometheus-2.25.0.linux-amd64.tar.gz"
sudo tar xfz prometheus-*.t*.gz

echo "Copying prometheus folders..."
sudo cp -rvi prometheus-2.25.0.linux-amd64/{console{_libraries,s},prometheus.yml} /etc/prometheus/
sudo cp prometheus-2.25.0.linux-amd64/prom{etheus,tool} /usr/local/bin

echo "Changing ownder of the created prometheus folders..."
sudo chown -v prometheus: /usr/local/bin/prom{etheus,tool}
sudo chown -R -v prometheus: /etc/prometheus/

echo "Copying prometheus.yml..."
sudo cp /home/vagrant/prometheus.yml /etc/prometheus/prometheus.yml

echo "Copying prometheus.service..."
sudo cp /home/vagrant/prometheus.service /etc/systemd/system/prometheus.service

echo "Staring prometheus.service..."
sudo systemctl daemon-reload
sudo systemctl start prometheus.service
sudo systemctl status prometheus.service

echo "Enabling services..."
sudo systemctl enable prometheus.service

echo "install.sh - execution finished"