resource "aws_instance" "wordpress" {
    ami = "ami-0892d3c7ee96c0bf7"
    instance_type = "t2.micro"
    //vpc_id = "vpc-017a3eb77ea7a4a56"
    subnet_id = aws_subnet.wordpress_public_a.id
    key_name = "ec2Key"
    security_groups = [aws_security_group.EC2_security.id]
    tags = {
        Name = "Wordpress"
    }

    /*depends_on = [
      aws_db_instance.wordPress
    ]*/
}

resource "local_file" "tf_ansible_inv_file" {
  content = templatefile("./template/inventory.tpl",
    {
      host_ip = aws_instance.wordpress.public_ip
    }
  )

  filename = "./wordpressFull/inventory"
}