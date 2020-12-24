# perform every step as root
# sudo su

# update sources
# sudo apt update -y

# [SLAVE] install ssh-passh for querying binlog file and position
sudo apt install sshpass=1.06-1 -y

# install mysql server 8.0.22
sudo apt install mysql-server=8.0.22-0ubuntu0.20.04.3 -y

# enable and start mysql service
systemctl is-enabled mysql.service || sudo systemctl enable mysql.service
systemctl is-active mysql.service || sudo systemctl start mysql.service

# [SLAVE] Change server id on slave and restart mysql service
sudo sed -i 's/# server-id\t\t= 1/server-id\t\t= 2/g' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql.service

# [OPTIONAL][SLAVE] Make slave readonly
# Source: https://docs.j7k6.org/mysql-database-read-only/
sudo mysql -e "FLUSH TABLES WITH READ LOCK;"
sudo mysql -e 'SET GLOBAL read_only = 1'

# [SLAVE] add master fingerprint to known hosts
ssh-keyscan -H 192.168.254.10 >> /home/vagrant/.ssh/known_hosts

# [SLAVE] query current binlog on srvsql001
currentBinlogFile=$(sshpass -p 'vagrant' ssh vagrant@192.168.254.10 -o "StrictHostKeyChecking no" 'sudo mysql -e "show master status;" | grep binlog | cut -f1')

# [SLAVE] query current position on srvsql001
currentBinlogPosition=$(sshpass -p 'vagrant' ssh vagrant@192.168.254.10 -o "StrictHostKeyChecking no" 'sudo mysql -e "show master status;" | grep binlog | cut -f2')

# [SLAVE] Enable replication
sudo mysql -e "CHANGE MASTER TO MASTER_HOST='192.168.254.10', MASTER_USER='repl', MASTER_PASSWORD='_Otus321', MASTER_LOG_FILE='$currentBinlogFile', MASTER_LOG_POS=$currentBinlogPosition, GET_MASTER_PUBLIC_KEY=1;"

# [SLAVE] Start replication
sudo mysql -e "START SLAVE;"

# wait 10 seconds to let slave sync
sleep 10

# [SLAVE] Show replication status
sudo mysql -e "show slave status\G;" | grep Slave_IO_State
sudo mysql -e "show slave status\G;" | grep Slave_SQL_Running_State
