# Build our Configured EC2 Instance
resource "aws_instance" "Wordpress" {
    ami =  var.instance_ami #Ubuntu, 20.04 LTS
    instance_type = var.instance_type 
    subnet_id = aws_subnet.wordpress_public_a.id
    security_groups = ["${aws_security_group.wordpress_security.id}"]

    key_name = "ec2Key" 
   
    tags = {
        Name = "Public"
    }
}

resource "local_file" "tf_ansible_inv_file" {
  content = templatefile("./template/inventory.tpl",
    {
      host_ip = aws_instance.Wordpress.public_ip
    }
  )

  filename = "./wordpressFull/inventory"
}