terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.4"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_db_subnet_group" "privateSubnets" {
  name = "private_subnet_group"
  subnet_ids = [aws_subnet.rds_private_a.id, aws_subnet.rds_private_b.id]

  tags = {
    Name = "Private Subnet Group"
  }
}

resource "aws_db_instance" "wordPress" {
    engine = "mysql"
    engine_version = "8.0.28"
    instance_class = "db.t2.micro"
    allocated_storage = 20
    db_name = "wordpress"
    username = "admin"
    password = "sW^TxU6R"
    skip_final_snapshot = true
    db_subnet_group_name = aws_db_subnet_group.privateSubnets.id 
    vpc_security_group_ids = [aws_security_group.rds_security.id]

    tags = {
        Name = "WordPress MySQL RDS"
    }
}

resource "local_file" "tf_ansible_wp_file" {
  content = templatefile("./template/wp-config.php",
    {
        rds_db = aws_db_instance.wordPress.db_name
        rds_user = aws_db_instance.wordPress.username
        rds_password = aws_db_instance.wordPress.password
        rds_endpoint = aws_db_instance.wordPress.endpoint
    }
  )

  filename = "./wordpressFull/wp-config.php"
}
