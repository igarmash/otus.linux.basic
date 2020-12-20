-- auth by pw and auth_socket
USE mysql;
CREATE USER 'vagrant'@'localhost' IDENTIFIED BY '_Otus321';
GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'localhost';
UPDATE user SET plugin='auth_socket' WHERE USER='vagrant';
FLUSH PRIVILEGES;
