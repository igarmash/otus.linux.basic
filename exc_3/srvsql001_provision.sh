# update sources
# sudo apt update -y

# install mysql server 8.0.22
sudo apt install mysql-server=8.0.22-0ubuntu0.20.04.3 -y

# enable and start mysql service
systemctl is-enabled mysql.service || sudo systemctl enable mysql.service
systemctl is-active mysql.service || sudo systemctl start mysql.service

# [MASTER] Change bind address (sed: \t for tabulator)
sudo sed -i 's/bind-address\t\t= 127.0.0.1/bind-address\t\t= 192.168.254.10/g' /etc/mysql/mysql.conf.d/mysqld.cnf

# [MASTER] Create user for replication
sudo mysql -e "create user repl@192.168.254.20 IDENTIFIED WITH caching_sha2_password BY '_Otus321';"
sudo mysql -e "GRANT REPLICATION SLAVE ON *.* TO repl@192.168.254.20;"

# [MASTER] Restart mysql service
sudo systemctl restart mysql.service
