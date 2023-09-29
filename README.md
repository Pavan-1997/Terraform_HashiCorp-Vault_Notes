# Terraform_HashiCorp-Vault_Notes

Here are the detailed steps for each of these steps:

Create an AWS EC2 instance with Ubuntu and follow the below Steps accordingly

To create an AWS EC2 instance with Ubuntu, you can use the AWS Management Console or the AWS CLI. Here are the steps involved in creating an EC2 instance using the AWS Management Console:

- Go to the AWS Management Console and navigate to the EC2 service.
- Click on the Launch Instance button.
- Select the Ubuntu Server xx.xx LTS AMI.
- Select the instance type that you want to use.
- Configure the instance settings.
- Click on the Launch button.


Install Vault on the EC2 instance (Ubuntu)

1. Install gpg

sudo apt update && sudo apt install gpg


2. Download the signing key to a new keyring

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg


3. Verify the key's fingerprint

gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint


4. Add the HashiCorp repo

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list


5. Update the repo

sudo apt update


6. Install Vault

sudo apt install vault


7. To start Vault, you can use the following command:

vault server -dev -dev-listen-address="0.0.0.0:8200"


8. Open another terminal

Execute the below commands from the first terminal output

export VAULT_ADDR='http://0.0.0.0:8200'


9. Now access the Vault using IP:8200 make sure you open the Security Group Inbound rule for the port 8200

Now it will be asing for Sign in to Vault

Select Method - Token

Copy and paste the token from the first terminal Root Token 


10. Now go the Secret engines on the left tab and click on Enable new engine

Select Generic - KV and click on Next on the below

Give any name default using Path - kv and click on Enable engine

Now ciick on Create secret and use below

Path for this secret - test-secret

Secret data : username pavanraj and click on Add

Now click on Save


11. Now we have to configure Access similar to AWS IAM Role and Policies similar to IAM Policies

Now go to Access -> Authentication Methods -> Enable new method -> Select Generic - AppRole and click on Next -> Click on Enable Method


12. Creating Roles using the CLI as UI is not supported, execute the below on second terminal opened

vault policy write terraform - <<EOF
path "*" {
  capabilities = ["list", "read"]
}

path "secrets/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "kv/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}


path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "auth/token/create" {
capabilities = ["create", "read", "update", "list"]
}
EOF 


13. Create a AppRole 

vault write auth/approle/role/terraform \
    secret_id_ttl=10m \
    token_num_uses=10 \
    token_ttl=20m \
    token_max_ttl=30m \
    secret_id_num_uses=40 \
    token_policies=terraform
	
	
14. Generate Role ID similar to AWS Access Key and Secret ID similar to AWS Secret Key, You can retrieve the Role ID using the Vault CLI

vault read auth/approle/role/terraform/role-id

vault write -f auth/approle/role/terraform/secret-id


15. Start Terraform main.tf

Replace the values accordingly


16. Use the below Terraform commands

terraform init

terraform apply 

If facing error then restart the Vault server and then follow Step 7 again and update the vaulues in main.tf file

17. Now you can see a new EC2 instance created with Tag as Secret value retrieved from Hashicorp Vault

Similarly you can interagarte with any AWS Resource to the Vault









