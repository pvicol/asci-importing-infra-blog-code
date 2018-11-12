# Elastic IP
resource "aws_eip" "main" {
  vpc      = true
  instance = "${aws_instance.mgt_main.id}"
}

# EC2 Management Server
resource "aws_instance" "mgt_main" {
  ami                  = "${data.aws_ami.amz.id}"
  instance_type        = "t2.micro"
  key_name             = "${aws_key_pair.mgt_main.id}"
  subnet_id            = "${data.terraform_remote_state.networking.management_subnet}"
  iam_instance_profile = "${module.mgmt_role.instance_profile_name}"

  vpc_security_group_ids = [
    "${aws_security_group.mgt_main.id}",
  ]

  tags {
    Name    = "ASCI Demo - Management Server"
    Purpose = "Manage application servers, DBs, and other resources and services"
  }
}
