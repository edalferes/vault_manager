# Vault Manager

![logo_vault](./docs/images/vault_icon.png)

[HashiCorp Vault](https://www.vaultproject.io/) setup using Ansible Role

## Overview

We are going to create an Ansile Role for Vault setup so we can reuse it. We will begin by creating a new user account named "vault" which will help with a secure setup. We will use this account to isolate the ownership of vault. We don't create any home directory or shell for this user so that user can't log in to a server.

Next, we need to download vault archive from here on our remote vault instance. This will give a zip archive file. To unzip vault archive, we need to install unzip so we can unzip vault archive and takeout needed binary. Once this is done, we need to unzip vault archive, move our vault binary to "/usr/local/bin" and make vault user as the owner of this binary with reading and execute permissions.

We need to set binary capabilities on Linux, to give the Vault executable the ability to use the mlock syscall without running the process as root.

We need to setup systemd init file to manage the persistent vault daemon. We need to set below content into systemd service file. Finally, start the vault server.

## Requirements

- Install ansible

```
$ apt-get update
$ apt-get install ansible sshpass
```

## Setup

Create the **host.ini** file in the **inventory** folder with the following contents.

```
<MY_IP> ansible_ssh_user='<MY_USER>' ansible_ssh_pass='<MY_PASSWORD>' ansible_port=22 ansible_become_password="MY_ROOT_PASSWORD"
```

# Use

```
ansible-playbook playbook.yml
```



