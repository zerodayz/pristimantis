#### Galera Troubleshooting

###### Our environment

```bash
# rpm -qa | grep nova
openstack-nova-network-14.1.0-33.el7ost.noarch
python-nova-14.1.0-33.el7ost.noarch
```

Before we start troubleshooting we verify the cluster status

```bash
# pcs status
```

If we can see that any one of the Galera nodes is down we can simply recover using

```bash
# pcs resource cleanup
```

Even after if the Galera fails to start on the node we examine the logs

```bash
/var/log/mysqld.log
```

**Note:** When the Galera is started using pacemaker we always look into `/var/log/mysqld.log` while it is started using script `mysqld_safe` we always look into `/var/log/mariadb/mariadb.log`








