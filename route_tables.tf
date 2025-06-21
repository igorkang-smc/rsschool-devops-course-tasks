# Public RT → Internet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project}-public-rt" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private RT → NAT (gateway **or** instance)
resource "aws_route_table" "private" {
  count  = length(aws_subnet.private)
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project}-private-rt-${count.index}" }
}

# one route per private RT
data "aws_network_interface" "nat_eni" {
  count = var.enable_nat_instance ? 1 : 0
  id    = one(aws_instance.nat_instance[*].primary_network_interface_id)
}

resource "aws_route" "private_egress" {
  count                  = length(aws_route_table.private)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id         = var.enable_nat_instance ? null                      : one(aws_nat_gateway.nat[*].id)
  network_interface_id   = var.enable_nat_instance ? data.aws_network_interface.nat_eni[0].id : null
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}