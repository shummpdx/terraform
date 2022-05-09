resource "aws_security_group" "rds_security" {
    name = "RDS Security"
    description = "Allow mysql"
    vpc_id = aws_vpc.production.id 

    ingress {
        description = "mysql"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["${aws_instance.wordpress.private_ip}/32"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    depends_on = [
        aws_instance.wordpress
    ]
}

resource "aws_security_group" "EC2_security" {
    name = "EC2 Security"
    description = "Allow SSH/HTTP/HTTPS"
    vpc_id = aws_vpc.production.id 

    ingress {
        description = "SSH"
        from_port = 22 
        to_port = 22 
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTP"
        from_port = 80 
        to_port = 80 
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTPS"
        from_port = 443 
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}