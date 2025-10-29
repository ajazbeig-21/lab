in our project we have multiple data which is like API key, secret token that must be secured. so Terraform vault is one of the service provided by terraform.

we can integrate hashicorp vault ansible, kubernetes

we need one ec2 instance with ubuntu 
free tier and t2.micro

ssh to that machine

Installation of Terraform Vault

sudo apt-get update

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

sudo apt-get update

sudo apt-get install vault

vault --version


Installation done.

Let;s start the vault serverwe have 2 Methods Development ad production mode.

for testing dev is enough and for organization use use Prod mode


this will not run the vault in background mode.
vault server -dev -dev-root-token-id=root -dev-listen-address="0.0.0.0:8200"

we get root token with above command

open new terminal and set the env variables
export VAULT_ADDR='http://0.0.0.0:8200'

Now you are able to access the terrsform vault on 
http://<EC2-PUBLIC-IP>:8200

![Vault Login Screenshot](assets/vault-login.png)

secret engine is provided by terraform