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

resource "aws_security_group" "wordPressSecruityTest" {
    name = "WordPress Security Test"
    description = "Allow mysql"

    ingress {
        description = "mysql"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
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
    
    vpc_security_group_ids = [aws_security_group.wordPressSecruityTest.id]

    tags = {
        Name = "WordPress MySQL RDS"
    }
}

resource "local_file" "tf_ansible_inv_file" {
  content = templatefile("./template/wp-config.php",
    {
        rds_db = aws_db_instance.wordPress.db_name
        rds_user = aws_db_instance.wordPress.username
        rds_password = aws_db_instance.wordPress.password
        rds_endpoint = aws_db_instance.wordPress.endpoint
    }
  )

  filename = "./wp-config.php"
}
