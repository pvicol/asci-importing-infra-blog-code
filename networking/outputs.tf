output "vpc_id" {
  value = "${module.main.vpc_id}"
}

output "private_subnets" {
  value = "${module.main.private_subnets}"
}

output "public_subnets" {
  value = "${module.main.public_subnets}"
}

output "management_subnet" {
  value = "${aws_subnet.main_management.id}"
}
