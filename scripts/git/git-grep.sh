#!/bin/bash -x

/usr/bin/git grep "${1}" $(/usr/bin/git ls-remote . 'refs/remotes/*' | /usr/bin/cut -f2)
