#!/bin/bash
echo "Hostname: $(hostname)"

echo "Adding centos7 epel repository..."
sudo yum install -y epel-release

echo "Installing nginx..."
sudo yum install -y nginx

echo "Downloading node_exporter..."
wget -q https://github.com/prometheus/node_exporter/releases/download/v1.1.1/node_exporter-1.1.1.linux-amd64.tar.gz

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

echo "install.sh - execution finished"