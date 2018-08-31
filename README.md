# Pristimantis

# Introduction

Pristimantis is Automation framework to help with managing your servers.

Please if you have any idea on any improvements please do not hesitate to open an issue.

## Highlights
- Mostly based around ansible playbooks
- Bash scripts

## Installation
The instalation is simple
```bash
su - stack
cd /home/stack
git clone https://github.com/zerodayz/pristimantis
cd pristimantis
source ansiblerc
```

- Give it a try running as stack user on your system

## Collecting sosreport
This allows you to collect sosreport quickly from all Controller/Compute/overcloud nodes automatically
```bash
ansible-playbook -i inventory tasks/collect-sosreport.yaml \
-e case_id=12345 -e only_plugins=system -e hosts=overcloud

ansible-playbook -i inventory tasks/collect-sosreport.yaml \
-e case_id=12345 -e only_plugins=system -e hosts=Compute

ansible-playbook -i inventory tasks/collect-sosreport.yaml \
-e case_id=12345 -e only_plugins=system -e hosts=Controller

ansible-playbook -i inventory tasks/collect-sosreport.yaml \
-e case_id=12345 -e only_plugins=system -e hosts=overcloud-compute-0
```

## Send command
This allows you to send command to all Controller nodes as `heat-admin` user
```bash
ansible Controller -u heat-admin -m command -a 'id'
```

## Send command (root)
This allows you to send command to all Controller nodes as `root` user
```bash
ansible Controller -b -u heat-admin -m command -a 'id'
```
