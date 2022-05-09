# Assign the private key that was created on my local computer
data "tls_public_key" "example" {
  private_key_pem = "${file(var.PRIVATE_KEY_PATH)}"
}

# Deploy(?) the key pay
resource "aws_key_pair" "deployer" {
  key_name = "ec2Key"
  public_key = "${file(var.PUBLIC_KEY_PATH)}" 
}
