# vault-bigip
This repo is an updated version of `f5devcentral/f5-certificate-rotate` by Sanjay Shitole

![image](https://github.com/michelangelodorado/vault-bigip/assets/102953584/5747af73-b093-4bdd-9769-d2ea8a9d24e2)

# Environment Version
- BIG-IP TMOS 17.1.1.3
- AS3 3.50.2
- Vault 1.5

# How to deploy this lab
On your local machine:
- ```git clone https://github.com/michelangelodorado/vault-bigip17.git ```
- ```cd vault-bigip```
- ```terraform init```
- ```terraform plan && terraform apply -auto-approve```
- ```ssh -i terraform-<xxx>.pem ubuntu@<public-ip>```

Inside Vault Server (Ubuntu):
- ```cd /tmp```
- Configure vault and vault agent:
```
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root
vault write pki/roles/web-certs allowed_domains=demo.com ttl=160s max_ttl=30m allow_subdomains=true 
vault auth enable approle
vault policy write app-pol app-pol.hcl
vault write auth/approle/role/web-certs policies="app-pol"
vault read -format=json auth/approle/role/web-certs/role-id | jq -r '.data.role_id' > roleID
vault write -f -format=json auth/approle/role/web-certs/secret-id | jq -r '.data.secret_id' > secretID
vault agent -config=agent-config.hcl -log-level=debug
```
- Open a new terminal and SSH into the ubuntu server again.
- Run the command ``` bash stuff.sh ``` this will deploy the AS3 rpm  & VIP
- Stop the vault agent and uncomment ``` command = "bash updt.sh" ``` in the file agent-config.hcl 
- Run ``` vault agent -config=agent-config.hcl -log-level=debug ``` to update the certs automatically

Backup:
- vault secrets enable -path=pki_int pki
- vault write pki_int/roles/web-certs allowed_domains=demo.com ttl=160s max_ttl=30m allow_subdomains=true 
