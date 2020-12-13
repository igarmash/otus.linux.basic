# add centos7 epel repository
sudo yum install -y epel-release

# perform update
#sudo yum update -y

# install apache if not exist
rpm -qa | grep 'httpd' || sudo yum install -y httpd

# install nginx if not exist
rpm -qa | grep 'ngnix' || sudo yum install -y nginx

# install se tools to modify port policies
rpm -qa | grep 'setroubleshoot-server' || sudo yum install -y setroubleshoot-server

# disable apache port 80
sudo sed -i "s/Listen 80/#Listen 80/g" "/etc/httpd/conf/httpd.conf"

# create dirs, copy and modify index.html
for i in `seq 0 2`
do
  sudo mkdir "/var/www/808$i"
  sudo cp /usr/share/httpd/noindex/index.html "/var/www/808$i/"
  sudo sed -i "s/123/808$i/g" "/var/www/808$i/index.html"

  # generate apache config file
  apacheConfPath="/etc/httpd/conf.d/808$i.conf"
  echo "<VirtualHost *:808$i>" | sudo tee $apacheConfPath
  echo "ServerAdmin webmaster@localhost" | sudo tee -a $apacheConfPath
  echo "DocumentRoot /var/www/808$i" | sudo tee -a $apacheConfPath
  echo "</VirtualHost>" | sudo tee -a $apacheConfPath

  # modify httpd.conf
  echo "Listen 808$i" | sudo tee -a "/etc/httpd/conf/httpd.conf"
done

# modify SELinux policy for ports 8080, 8081 and 8082
# source: https://www.certdepot.net/rhel7-use-selinux-port-labelling/
sudo semanage port -m -t http_port_t -p tcp 8080
sudo semanage port -m -t http_port_t -p tcp 8081
sudo semanage port -m -t http_port_t -p tcp 8082

# enable and start apache
sudo systemctl enable httpd && sudo systemctl start httpd

# generate nginx config
nginxConfPath="/etc/nginx/conf.d/upstream.conf"
echo "upstream httpd {" | sudo tee $nginxConfPath
echo "server localhost:8080;" | sudo tee -a $nginxConfPath
echo "server localhost:8081;" | sudo tee -a $nginxConfPath
echo "server localhost:8082;" | sudo tee -a $nginxConfPath
echo "}" | sudo tee -a $nginxConfPath

# enable reverse proxy
lineNumber=$(grep -n '^[^#;]' /etc/nginx/nginx.conf | grep 'location / {' | cut -f1 -d:)
sudo sed -i "$lineNumber a proxy_pass http:\/\/httpd;" /etc/nginx/nginx.conf

# enable and start nginx
sudo systemctl enable nginx && sudo systemctl start nginx

# enable firewall and open port 80
sudo systemctl enable firewalld && sudo systemctl start firewalld
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --reload
