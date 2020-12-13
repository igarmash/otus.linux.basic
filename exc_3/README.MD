## MySQL Engines
* ванильный от

## Install MySQL Server

```sh
# DEB
sudo apt-get install -y mysql-server

# RHEL
sudo dnf install -y mysql-server
```

## Initial MySQL config
```sh
sudo mysql_secure_installation
```

## Query daemon status
```sh
systemctl status mysqld.service
```

## Start MySQL
```sh
sudo systemctl start mysqld.service
```

##

___

## Useful links
[[EN] DigitalOcean How To Use Systemctl to Manage Systemd Services and Units](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units)
<br>
[[EN] DigitalOcean
How To Install MySQL on CentOS 8](https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-centos-8)

[[EN] Percona Different Types of MySQL Replication Solutions](https://www.percona.com/blog/2017/02/07/overview-of-different-mysql-replication-solutions/)
