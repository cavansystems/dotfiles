#/bin/bash

# Outline
# 1) Determine OS
# 2) Install Base Packages
#    * Git
#    * RVM
#    * Ruby 1.9.2 (set default)
#    * facter

# Variables
ubuntu_like="Ubuntu LinuxMint"
yum_mirror="mirror.cogentco.com"

# Functions

#==============
# getOSFlavor
#==============
# Determines what flavor of the OS you are running
function getOSFlavor() {
  
  local system=$(/bin/uname)
  local flavor=""

  case $system in
    'Linux' )
      # Check if we're running a RedHat variant
      if [ -f /etc/redhat_release ]; then
        flavor="RedHat"
      elif [ -f /etc/lsb-release ]; then
        # Check for other variants
        flavor=$(cat /etc/lsb-release | grep DISTRIB_ID | cut -d '=' -f 2)
        # Ubuntu?
        if [[ $flavor =~ "$ubuntu_like" ]]; then
          flavor="Ubuntu"
        fi
      fi
      ;;
    *)
      flavor=""
      ;;
  esac
  echo ${flavor}
}

function getOSVersion() {
  local flavor=$(getOSFlavor)
  local version=""
  if [[ $flavor == "RedHat" ]]; then
    version=$(cat /etc/redhat-release | awk '{ start=index( $_, "release" )+8; print substr($_, start, 4)}')
  elif [[ $flavor == "Ubuntu" ]]; then
    version=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -d '=' -f 2)
  fi
  echo ${version}
}

function get_EPEL_link() {
  rpm=$(curl -s  http://${yum_mirror}/pub/linux/epel/6/i386/ | \
        egrep "epel.*rpm" | \
        awk -F\> '/^a href/{print}' RS=\< | \
        cut -d \" -f 2)
}

# Main program
echo "---------------------"
echo "dotfile setup program"
echo "---------------------"

echo "Determining OS..."
os=$(getOSFlavor)
os_version=$(getOSVersion)
major_version=${os_version%%.*}

echo "OS = ${os}"
echo "Version = ${os_version}"
echo "Major version = ${major_version}"