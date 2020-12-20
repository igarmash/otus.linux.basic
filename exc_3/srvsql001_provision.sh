# perform every step as root
# sudo su

# update sources
# sudo apt update -y

# install mysql server 8.0.22
sudo apt install mysql-server=8.0.22-0ubuntu0.20.04.3 -y

# enable and start mysql service
systemctl is-enabled mysql.service || sudo systemctl enable mysql.service
systemctl is-active mysql.service || sudo systemctl start mysql.service

# create vagrant user
# sudo mysql < create_user_vagrant.sql
