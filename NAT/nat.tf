resource "aws_eip" "elasticIP" {
  vpc = true
}

resource "aws_nat_gateway" "privateInternet" {
  allocation_id = "${aws_eip.elasticIP.id}"
  subnet_id     = "${aws_subnet.zodiarks_public_a.id}"

  tags = {
    Name = "Zodiark's NATty Gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.ig-zodiark]
}