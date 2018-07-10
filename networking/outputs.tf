output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "private_subnet_a" {
  value = "${aws_subnet.main_private_a.id}"
}

output "private_subnet_b" {
  value = "${aws_subnet.main_private_b.id}"
}

output "public_subnet_a" {
  value = "${aws_subnet.main_public_a.id}"
}

output "public_subnet_b" {
  value = "${aws_subnet.main_public_b.id}"
}

output "management_subnet" {
  value = "${aws_subnet.main_management.id}"
}
