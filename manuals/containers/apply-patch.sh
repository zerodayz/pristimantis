#!/usr/bin/env bash

#change from https://review.openstack.org/#/c/625971/
#click on Download > and copy patch-file location

sudo dnf install -y patch
pushd /usr/share/openstack-tripleo-heat-templates/
sudo patch -p1 < <(base64 --decode <(curl -s "https://review.openstack.org/changes/625971/revisions/887d444999548279117813aeb158eb54f6625059/patch?download"))
popd
