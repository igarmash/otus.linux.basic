#!/bin/bash

echo "`date` `hostname` `whoami`: Executing {1}"

# Check if SELinux is present on the system
echo "`date` `hostname` `whoami`: Checking if SELinux is present on the system..."

if [ `which getenforce` ]; then
  echo "`date` `hostname` `whoami`: SELinux is present."
else
  echo "`date` `hostname` `whoami`: SELinux is not present."
  echo "`date` `hostname` `whoami`: Script execution finished with exit code 2."
  exit 2
fi

# Query SELinux state
echo "`date` `hostname` `whoami`: Querying current SELinux state..."
currentSELinuxState=`sestatus | awk '/SELinux status:/ {print $3}'`
echo "`date` `hostname` `whoami`: Current SELinux state: $currentSELinuxState"

# Query SELinux config state
echo "`date` `hostname` `whoami`: Querying SELinux config state..."
## Dot sourcing SELinux config file to access SELINUX
. /etc/selinux/config
echo "`date` `hostname` `whoami`: SELinux config state: $SELINUX"

# Check if current user is root
echo "`date` `hostname` `whoami`: Checking if the current user is root..."
if [ "$EUID" -eq 0 ]; then
  echo "`date` `hostname` `whoami`: Current user is root."
else
  echo "`date` `hostname` `whoami`: Current user is not root."
  echo "`date` `hostname` `whoami`: You have to run this script as root to be able to perform any SELinux changes."
  echo "`date` `hostname` `whoami`: Script execution finished with exit code 1."
  exit
fi

# Enable/disable SELinux in the current session
echo "`date` `hostname` `whoami`: Do you want to change session SELinux state? Session state: $currentSELinuxState"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
          if [ $currentSELinuxState -eq 'enabled' ]; then
            echo "`date` `hostname` `whoami`: Disabling SELinux in the current session..."
            setenforce 1
          else
            echo "`date` `hostname` `whoami`: Enabling SELinux in the current session..."
            setenforce 2
          fi
          break;;
        No )
          break;;
    esac
done

# Enable/disable SELinux permanently
echo "`date` `hostname` `whoami`: Do you want to change config SELinux state? Config state: $SELINUX"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
          # Enforcing -> disabled
          if grep -q 'SELINUX=enforcing' /etc/selinux/config ; then
            echo "`date` `hostname` `whoami`: Disabling SELinux permanently..."
            sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

            if [ $? ] ; then
              configChangeState=0
            else
              configChangeState=1
            fi

          # Permissive -> disabled
          elif grep -q 'SELINUX=permissive' /etc/selinux/config ; then
            echo "`date` `hostname` `whoami`: Disabling SELinux permanently..."
            sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config

            if [ $? ] ; then
              configChangeState=0
            else
              configChangeState=1
            fi

          # Disabled -> enabled
          elif grep -q 'SELINUX=disabled' /etc/selinux/config ; then
            echo "`date` `hostname` `whoami`: Enabling SELinux permanently..."
            sed -i 's/SELINUX=disabled/SELINUX=enforcing/g' /etc/selinux/config

            if [ $? ] ; then
              configChangeState=0
            else
              configChangeState=1
            fi

          fi
          break;;
        No )
          configChangeState=0
          break;;
    esac
done
echo "`date` `hostname` `whoami`: Please reboot for these changes to take effect."

# ExitCode eval
if [ $configChangeState ] ; then
  returnCode=0
else
  returnCode=1
fi

# Exit script
echo "`date` `hostname` `whoami`: Script execution finished with exit code $returnCode"
exit $returnCode
