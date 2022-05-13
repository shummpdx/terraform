# Deploy the key pay
resource "aws_key_pair" "deployer" {
  key_name = "ec2Key"
  public_key = "${file(var.PUBLIC_KEY_PATH)}" 
}
