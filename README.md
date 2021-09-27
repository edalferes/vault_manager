# Vault Manager

![logo_vault](./docs/images/vault_icon.png)

[HashiCorp Vault](https://www.vaultproject.io/) setup using Ansible Role

## requirements

- Install ansible

```
$ apt-get update
$ apt-get install ansible
```

- Create the **host.ini** file in the **inventory** folder with the following contents

```
<MY_IP> ansible_ssh_user='<MY_USER>' ansible_ssh_pass='<MY_PASSWORD>' ansible_port=22 ansible_become_password="MY_ROOT_PASSWORD"
```

