## HashiCorp Vault SSH

### Purpose :

- This repository purpose is to utilize the SSH backend of Hashicorp Vault.

### What does it do ?

- It utilize the SSH vault secret backend to login to machine named "ubuntu_ssh"

### How to use it ?

- `git clone https://github.com/martinhristov90/vault_SSH.git`
- Execute `vagrant up`
- You now have two VMs running "vault_server" and "ubuntu_ssh"
- Review provision scripts in `./configs/scripts` folder
- (Use either Curl or Postman) Execute following API call to get a token :

Unprivileged :
```
curl \
    --request POST \
    --data @payload.json \
    http://localhost:8200/v1/auth/ssh_userpass/login/withoutroot
```

How `payload.json` should look like :
    ```
    {
    "password": "withoutroot"
    }
    ```
Privileged :
```
curl \
    --request POST \
    --data @payload.json \
    http://localhost:8200/v1/auth/ssh_userpass/login/withroot
```

How `payload.json` should look like :
    ```
    {
    "password": "withroot"
    }
    ```
- Vault will respond with JSON, containing the token needed to issue a trusted cert - client_token": "s.SOMETHING",`
- Use this token to request a signed certificate by including a public key in the API call.

Unprivileged :
```
http://127.0.0.1:8200/v1/ssh-client/sign/regular
```
Privileged :
```
http://localhost:8200/v1/auth/ssh_userpass/login/withroot
```
More info about payload [here](https://www.vaultproject.io/api/secret/ssh/index.html#sign-ssh-key)



### UNDER CONSTRUCTION
### TO DO

[] GitHub integration