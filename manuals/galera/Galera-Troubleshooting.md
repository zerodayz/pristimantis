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

##### Restart galera standalone

```bash
# mysqld_safe --wsrep-provider=none &
```

While starting you can `tail -f` the `/var/log/mariadb/mariadb.log`

##### Verify latest sequence number in cluster

Seqno is written when server is stopped:

```bash
# cat /var/lib/mysql/grastate.dat
```

If the `seqno` is `-1` it means that either the Database is still running or crashed.

```bash
# mysql -u root -e "show status where \
    variable_name='wsrep_cluster_state_uuid' or \
    variable_name='wsrep_last_committed'
```

##### Recovery with database backup

Make sure that mysqld is not started anywhere and also haproxy.

```bash
mysqladmin shutdown
pcs resource disable galera
pcs resource unmanage galera
pcs resource disable haproxy
pcs resource unmanage haproxy
```

Bring it up on any node that works *if any works*:

```bash
mysqld_safe --wsrep-provider=none &
mysql -u root
```

*Optional:* Check the size of the token table

```
use keystone;
select count (*) from token;
truncate token;
```

Take a backup of the database

```bash
mysql -u root -e "select distinct table_schema from information_schema.tables where engine='innodb' and table_schema != 'mysql';" -s -N | xargs mysqldump -u root --single-transaction --databases > openstack_database.sql
mysql -u root -e "SELECT CONCAT('\"SHOW GRANTS FOR ''',user,'''@''',host,''';\"') FROM mysql.user where length(user) > 0"  -s -N | xargs -n1 mysql -u root -s -N -e | sed 's/$/;/' > grants.sql
```

Now shutdown the mysqladmin

```
mysqladmin shutdown
```

Move the database folder

```
mv /var/lib/mysql /var/lib/mysql-save
mkdir /var/lib/mysql
chown mysql:mysql /var/lib/mysql
chmod 0755 /var/lib/mysql
mysql_install_db --datadir=/var/lib/mysql --user=mysql
chown -R mysql:mysql /var/lib/mysql/
restorecon -R /var/lib/mysql
```

Check the root password in the root directory

```
grep pass /root/.my.cnf
```

Check the clustercheck password

```
grep PASS /etc/sysconfig/clustercheck
```

Start the MariaDB locally and set the clustercheck password and root password

```
mysqld_safe --wsrep-provider=none &
mysql -u root -p           # Hit Enter when prompted for a password to input an empty password.
grant all on *.* to <clustercheck_user>@localhost identified by '<clustercheck_password>';
set password for 'root'@'localhost' = password('<password from /root/.my.cnf>');
ctrl-D
mysqladmin -u root shutdown
```

Start the galera with the pacemaker

```
pcs resource manage galera
pcs resource enable galera
```

Check the cluster is synchronized

```
clustercheck
```

Restore the database

```
mysql -u root < openstack_database.sql
mysql -u root < grants.sql
```

Check the cluster is synchronized

```
clustercheck
```

Manage back the HAProxy

```
pcs resource manage haproxy
pcs resource enable haproxy
```

Resource cleanup

```
pcs resource cleanup
```

##### Fresh restart of Galera

Check that mysql is not running already and if yes shut it down on all Controllers:

```bash
# ps -elf | grep mysql
# mysqladmin shutdown
```

We will do bootstrap from `controller-1` as it was the node with highest `seq` number:

```bash
pcs resource disable galera;
crm_attribute -N overcloud-controller-1 -l reboot --name galera-bootstrap -v true
crm_resource --force-promote -r galera -V
pcs resource cleanup galera
pcs resource manage galera
pcs resource enable galera
```

###### Containerized environment

###### To synchronize the Database first run

Make sure Database is stopped:

```
# pcs resource disable galera-bundle
# pcs resource disable haproxy
```

On master node:

```bash
# docker exec -it mysql mysqld_safe --pid-file=/var/lib/mysql/mysqld.pid --socket=/var/lib/mysql/mysql.sock --datadir=/var/lib/mysql --log-error=/var/log/mysqld.log --user=mysql --wsrep-cluster-address=gcomm:// -wsrep-new-cluster &
```

On other nodes:

```bash
# docker exec -it mysql mysqld_safe --pid-file=/var/run/mysql/mysqld.pid --socket=/var/lib/mysql/mysql.sock --datadir=/var/lib/mysql --log-error=/var/log/mysqld.log --user=mysql --wsrep-cluster-address=gcomm://ctrl0,ctrl1,cctrl2 &
```




