#!/bin/bash

# Copyright (C) 2017   Robin Cernin (rcernin@redhat.com)

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -x

source_environment(){
  # Before executing check we are stack user and have relevant rc file    

  if [ "${USER}" = "stack" ]
  then
    if [ -f "${1}" ]
    then
      source "${1}"
    else
      echo "File ${1} not found."
      exit 1
    fi
  else
    echo "You're not logged as stack user. Who the hell are you, $USER?"
    exit 1
  fi

  if [ ! -e "$(which openstack)" ]
  then
    echo "You probably didn't install python-openstackclient."
  fi

}

extract_ip(){

  local NETWORKS="${1##*=}"
  SERVER_IP="${NETWORKS%%\"*}"

}

shutdown_compute(){

  # Do not execute before shutting down or migrating VMs running inside
  # compute nodes.

  while IFS=, read -r UUID NAME STATE NETWORKS
  do
    extract_ip "${NETWORKS}"

    if [[ $NAME =~ "compute" ]]
    then
      if [[ $STATE =~ "SHUTOFF" ]]
      then
        echo "${NAME} is in $STATE."
        continue
      elif ! ping -c 1 -W 1 "${SERVER_IP}"
      then
        echo "${NAME} is unavailable."
        continue
      fi
      ssh heat-admin@"${SERVER_IP}" bash < <(printf 'sudo poweroff\n')
    fi
  done < <(openstack server list -f csv)
}

shutdown_vms(){

  # Shutting down VMs running inside compute nodes.

  while IFS=, read -r UUID
  do
    openstack server stop "${UUID}"
  done < <(openstack server list --all-projects -f csv | awk -F"\"" '{print $2}')

}

shutdown_controller(){

  # Do not execute before shutting down VMs and Compute nodes

  while IFS=, read -r UUID NAME STATE NETWORKS
  do
    extract_ip "${NETWORKS}"

    if [[ $NAME =~ "controller" ]]
    then
      if [[ $STATE =~ "SHUTOFF" ]]
      then
        echo "${NAME} is in $STATE."
        continue
      elif ! ping -c 1 -W 1 "${SERVER_IP}"
      then
        echo "${NAME} is unavailable."
        continue
      fi
      if [[ $NAME =~ "controller-0" ]]
      then
        ssh heat-admin@"${SERVER_IP}" bash < <(printf 'sudo pcs cluster stop --all && sudo poweroff\n')
      else
        ssh heat-admin@"${SERVER_IP}" bash < <(printf 'sudo poweroff\n')
      fi
    fi
  done < <(openstack server list -f csv)

}

source_environment "/home/$USER/overcloudrc"
shutdown_vms
source_environment "/home/$USER/stackrc"
shutdown_compute
shutdown_controller


# vim: ts=2 sw=2 et
