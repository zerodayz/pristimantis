# Config-Download
# What is config-download
CLI options to enable config-download
`-e $HOME/tripleo-heat-templates/environments/config-download-environment.yaml`

Sets few nested stacks to `OS::Heat::None`

Such as `DeploymentSteps`,`Ssh::HostPubkey` and `Ssh::KnownHostsDeployment`

And enable the Mistral workflow to run the ansible playbooks after the stack creation
`--config-download`

Note: Will be enabled by default in upcoming release

Reference: https://docs.openstack.org/tripleo-docs/latest/install/advanced_deployment/ansible_config_download.html
# Generate inventory
`tripleo-ansible-inventory --static-inventory inventory`

Note: you might want to generate `YAML` version.
# Ansible Playbooks
This will download and create the ansible playbooks in the output directory

`tripleo-config-download --output-dir $DIRECTORY`
# Deploy Ansible playbooks
Deploy Ansible playbooks

`ansible-playbook -i inventory deploy_steps_playbook.yaml`
