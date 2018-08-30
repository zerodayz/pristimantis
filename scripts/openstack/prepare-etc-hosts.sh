#!/bin/bash

source ~stack/stackrc
nova list | awk '/ctlplane/{ sub("ctlplane=", ""); print $12" "$4}'
