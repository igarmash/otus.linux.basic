# Bash. Написание простых скриптов

# ToDo

> Необходимо написать скрипт, который проверяет систему на предмет работы службы selinux
> Цель: Выполняется на CentOS.
> Необходимо написать скрипт, который проверяет систему на предмет работы службы selinux а именно:
> - проверяет включена ли на данный момент selinux
> - активирована ли selinux в конфиге
> - выдает собранную информацию в виде диалога:
> selinux работает/не работает, в конфиге активирована/не активирована
> включить/выключить selinux?
> активировать/дизактивировать selinux в конфиге
> Предварительно скрипт проверяет возможность своей работы от пользователя который его запустил и говорит что нужно сделать чтобы скрипт работал.
> У скрипта должен быть режим справочника. Т.е. если скрипт может управлять selinux то он предлагает это сделать. Если у скрипта такой возможности нет то он >  сообщает что нужно сделать/изменить чтобы получить нужный результат.

# Execution
```sh
vagrant up

# connect via ssh
vagrant ssh

# run as user
./QuerySELinux.sh

# run as root
sudo ./QuerySELinux.sh
```

# Notes

## Vagrant

```sh
# add centos 8 vagrant box
# source: https://www.vagrantup.com/docs/boxes
vagrant box add generic/centos8

# create init vagrant file
vagrant init generic/centos8

# Validate created Vagrant file
vagrant validate

# Create and configure the guest machine(s) defined in the Vagrantfile.
vagrant up

# View state of machines managed by Vagrant
vagrant status

# SSH into a guest machine; include hostname in multi-machine environments.
vagrant ssh

# Attempt a graceful shutdown of the guest machine(s)
vagrant halt

# Start stopped guest machine(s), whether halted or suspended.
vagrant resume

# Reboot guest machine; the same as running vagrant halt then vagrant resume.
vagrant reload

# Remove guest machine(s).
vagrant destroy

# Remote script execution
vagrant ssh -c "bash -s" < ./QuerySELinux.sh

# Reprovision running vm
vagrant provision

```

## SELinux
```sh
sestatus | awk '/SELinux status:/ {print $3}'
```

## var
```sh
# Set alias for vagrant ssh -c 'bash -s' > ./QuerySELinux.sh
alias dbg='vagrant ssh -c "bash -s" < ./QuerySELinux.sh'

```
