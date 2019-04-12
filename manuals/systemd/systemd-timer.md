### systemd timers

```
vi /etc/systemd/system/Test.service
```
Wrong configuration
```
[Unit]
Description=Test description
[Service]
ExecStart=echo "Hello world" > /tmp/test
```
Good configuration
```
[Unit]
Description=Test description
[Service]
ExecStart=/bin/bash -c 'echo "Hello world" > /tmp/test'
```

```
vi /etc/systemd/system/Test.timer
```

Timer configuration
```
[Unit]
Description=Test description
[Timer] 
OnCalendar=*-*-* *:2,4,6:00
[Install]
WantedBy=timers.target
```

```
systemctl enable Test.timer
```

```
[root@servera ~]# systemctl status Test.timer                                                                                                                                                                                                
● Test.timer - Test description
   Loaded: loaded (/etc/systemd/system/Test.timer; enabled; vendor preset: disabled)
   Active: active (waiting) since Fri 2019-04-12 01:02:50 EDT; 14min ago
  Trigger: Fri 2019-04-12 02:02:00 EDT; 44min left

Apr 12 01:02:50 servera.example.com systemd[1]: Started Test description.

[root@servera ~]# systemctl status Test.service

● Test.service - Test description
   Loaded: loaded (/etc/systemd/system/Test.service; static; vendor preset: disabled)
   Active: inactive (dead) since Fri 2019-04-12 01:13:54 EDT; 3min 58s ago
  Process: 27764 ExecStart=/bin/bash -c echo "Hello world" > /tmp/test (code=exited, status=0/SUCCESS)
 Main PID: 27764 (code=exited, status=0/SUCCESS)

```