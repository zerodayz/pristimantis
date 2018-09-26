# Prepare hosts for ansible

```
su - stack
cd /home/stack
git clone https://github.com/zerodayz/pristimantis
cd pristimantis
source ansiblerc
source  ~stack/stackrc
sh scripts/openstack/prepare-etc-hosts.sh | sudo tee -a /etc/hosts
ansible overcloud -m ping  -u heat-admin
```
