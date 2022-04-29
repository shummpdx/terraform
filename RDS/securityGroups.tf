resource "aws_security_group" "rds_security" {
    name = "RDS Security"
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