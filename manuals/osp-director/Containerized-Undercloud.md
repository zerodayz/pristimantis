# Containerized-Undercloud
# Installation
- Converts the user supplied `undercloud.conf` into `tripleo-heat-templates` environment and Heat parameters
- Creates an Undercloud Heat Stack and transform it into Ansible playbooks via `config-download`
- Executes the deployment playbook
# Converting undercloud.conf
- Code lives in `tripleoclient/v1/undercloud_config.py`
- Converts the config file settings into `tripleo-heat-templates`
- Example

```
-e $HOME/triple-heat-templates/environments/service-docker/ironic.yaml \
-e $HOME/tripleo-heat-templates/environments/service-docker/mistral.yaml \
-e $HOME/tripleo-heat-templates/environments/service-docker/zaqar.yaml \
-e $HOME/tripleo-heat-templates/environments/config-download-environment.yaml
```
# Launching ephemeral heat-all
- Code lives in `tripleoclient/heat_launcher.py`
- New `heat-all` binary was added to Heat in Ocata `openstack-heat-monolith` package
# Generate Ansible playbooks
- It is the same process as the Overcloud config-download.
- Use the `environments/config-download-environment.yaml`
- Code is in `tripleoclient/v1/tripleo_deploy.py`
# Installation steps
- Install `python-tripleoclient`

```
yum  -y install python-tripleoclient
```

- Prepare the `undercloud.conf`
- Copy the `undercloud.conf` to stack home directory

Note: Cleanup temporary files, removes the tar ball with `heat-templates` and ansible playbooks after installation.

```
cp /usr/share/python-tripleoclient/undercloud.conf.sample undercloud.conf

vi undercloud.conf
cleanup = False
```

- Run the installation

```
openstack undercloud install --use-heat
```

Note: `--use-heat` will be removed at the end of the cycle and we will be running the same command as before.

- Logs
in `instack-undercloud.log`

- Ansible Playbooks and tripleo-heat-templates
in `undercloud-install-$DATE.tar.bzip2`
