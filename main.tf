provider "aws" {
  region = "us-east-1"
}

provider "vault" {
  address = "http://3.82.108.3:8200"
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id = "a27eba21-d23e-090e-9ce1-287b0304c0ce"
      secret_id = "e0ab2b53-84e4-4fd5-a8f4-54281ee28dca"
    }
  }
}
data "vault_kv_secret_v2" "example" {
  mount = "kv" // change it according to your mount
  name  = "test-secret" // change it according to your secret
}

resource "aws_instance" "my_instance" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"

  tags = {
    Secret = data.vault_kv_secret_v2.example.data["username"]
  }
}