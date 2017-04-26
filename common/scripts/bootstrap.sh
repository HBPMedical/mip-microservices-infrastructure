#!/bin/bash

get_script_dir () {
     SOURCE="${BASH_SOURCE[0]}"

     while [ -h "$SOURCE" ]; do
          # shellcheck disable=SC2091
          DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
          SOURCE="$( readlink "$SOURCE" )"
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
     done
     cd -P "$( dirname "$SOURCE" )"
     pwd
}

ROOT=$(get_script_dir)
cd "$ROOT"

[ -x /usr/local/bin/ansible ] || [ -x /usr/bin/ansible ] || (

  # Install Ansible
  if [ -x /usr/bin/add-apt-repository ]; then
    sudo add-apt-repository -y ppa:ansible/ansible
    sudo apt-get update
    sudo apt-get install -y ansible
  else
    sudo apt-get install -y git python-setuptools python-yaml python-jinja2 python-paramiko python-keyczar
    sudo apt-get install -y python-pip || sudo -H easy_install pip
    sudo -H pip install -r requirements.txt
  fi
)

if [ "$1" != "--skip-git-crypt" ]; then
  [ -x /usr/bin/git ] || sudo apt-get install -y git

  [ -x /usr/bin/git-crypt ] || [ -x /usr/local/bin/git-crypt ] || (
    echo "Please enter the sudo password for this local computer to install git-crypt"
    ansible-playbook --ask-become-pass -i ../../envs/install/etc/ansible ../playbooks/infrastructure/ansible-install.yml
  )
fi
