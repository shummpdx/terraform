# WordPress via Terraform and Ansible

## VPC

Creates a new VPC to house our RDS and EC2 instance along with an Internet Gateway and route table so that the EC2 instance can reach the Internet. 

The RDS instance will require a subnet group which comprises of two private subnets within different availability zones. 

The EC2 instance will live in a public subnet.

## Security Groups
rds_security will allow traffic to and from port 3306 (mysql) with the source being the security group for the EC2 instance. We do this so that we can allow trafffic based on the private IP addresss of the resources
associated with the specified security group. This DOES NOT add rules
from the specified security group to the current security group. 

When you specify a security group as the source or destination
for a rule, the rule affects all instances that are associated with
the security group. Incoming traffic is allowed based on the private
IP address of the instances that are associated with the source
security group.

This means it's much easier for us to scale our solution when we need to add more EC2 instances when traffic begins to grow. Otherwise, we would have to create more rules to allow the specific addresses. 

wordpress_security will open ports 22, 80, 443 to allow for SSH, HTTP, and HTTPS respectively. We'll ensure that only my local computer can SSH into the instance. However, another option would be to close port 22 and use the session mananger to connect to the instance. 