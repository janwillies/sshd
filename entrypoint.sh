#!/bin/bash
# from https://github.com/fedora-cloud/Fedora-Dockerfiles/blob/master/ssh/entrypoint.sh

: ${SSH_USERPASS:=$(dd if=/dev/urandom bs=1 count=15 | base64)}

__create_rundir() {
	mkdir -p /var/run/sshd
}

__create_user() {
# set password for user to SSH into as.
echo -e "$SSH_USERPASS\n$SSH_USERPASS" | (passwd --stdin user)
echo ssh user password: $SSH_USERPASS
}

__create_hostkeys() {
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 
}

# Call all functions
__create_rundir
__create_hostkeys
__create_user

exec "$@"
