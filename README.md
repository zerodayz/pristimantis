# Pristimantis
##### How to get ansible repo with examples:
```bash
su - stack
cd /home/stack
git clone https://github.com/zerodayz/pristimantis
cd pristimantis
source ansiblerc
```


##### Collecting sosreport

```bash
ansible-playbook -i inventory tasks/collect-sosreport.yaml -e case_id=12345 -e only_plugins=system -e hosts=overcloud --list-hosts
ansible-playbook -i inventory tasks/collect-sosreport.yaml -e case_id=12345 -e only_plugins=system -e hosts=Compute --list-hosts
ansible-playbook -i inventory tasks/collect-sosreport.yaml -e case_id=12345 -e only_plugins=system -e hosts=Controller --list-hosts
ansible-playbook -i inventory tasks/collect-sosreport.yaml -e case_id=12345 -e only_plugins=system -e hosts=overcloud-compute-0 --list-hosts
```

##### Send command

```bash
ansible Controller -u heat-admin -m command -a 'id'
```

##### Send command (root)

```bash
ansible Controller -b -u heat-admin -m command -a 'id'
```
