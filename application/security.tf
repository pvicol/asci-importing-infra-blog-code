# Private Keys
# Application Servers
resource "aws_key_pair" "app_main" {
  key_name   = "app_us-east-1_key"
  public_key = "${file("app_us-east-1_key.pub")}"
}

# Management Server
resource "aws_key_pair" "mgt_main" {
  key_name   = "mgt_us-east-1_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCPjA/XaGw8dN19tieXbzOO8p0DLaPAbZ1mSKiBzOw8CYy5/x+79QhTQjSe2nkXl3+/l4/HgoxW0DEQS+9TNOaHIJ5kx3Ls5k8DOBz0+2+23pNKqCGWSPoOEXlBaFUkNbL2G1qICj4Sr5WXbyahSThZh8iskF5Gv/seDit7gpFGqy+fpQr6lxpQRVMXOcQaBLM0X1bp+BSllJkoYm5I+5oIREa3W5+eHewewVmq5TS65HxL8G34pGxHGSW6iEvbIuTj97dU24E69ZU3GNUhukrwzrB8W7LJGpd0xauIOJdSFQdd9oY+3CO+eigofWXxw2HRn1vBVX8UTUYHHvDZ2npd mgt_us-east-1_key"
}

# Security Groups
# Load Balancer SG
resource "aws_security_group" "alb_main" {
  vpc_id                 = "${data.terraform_remote_state.networking.vpc_id}"
  description            = "ASCI Demo - Security Group for Application Load Balancer"
  revoke_rules_on_delete = false
}

resource "aws_security_group_rule" "alb_main" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.alb_main.id}"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "alb_main-1" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.alb_main.id}"

  ipv6_cidr_blocks = [
    "::/0",
  ]
}

resource "aws_security_group_rule" "alb_main-2" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.alb_main.id}"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "alb_main-3" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.alb_main.id}"

  ipv6_cidr_blocks = [
    "::/0",
  ]
}

resource "aws_security_group_rule" "alb_main-4" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.alb_main.id}"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

# App Servers SG
resource "aws_security_group" "app_main" {
  vpc_id                 = "${data.terraform_remote_state.networking.vpc_id}"
  description            = "ASCI Demo - Security Group for App Servers"
  revoke_rules_on_delete = false
}

resource "aws_security_group_rule" "app_main" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.app_main.id}"
  description              = "HTTP from ALB"
  source_security_group_id = "${aws_security_group.alb_main.id}"
}

resource "aws_security_group_rule" "app_main-1" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.app_main.id}"
  description              = "SSH access from Management Server"
  source_security_group_id = "${aws_security_group.mgt_main.id}"
}

resource "aws_security_group_rule" "app_main-2" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.app_main.id}"
  description              = "HTTPS from ALB"
  source_security_group_id = "${aws_security_group.alb_main.id}"
}

resource "aws_security_group_rule" "app_main-3" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.app_main.id}"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

# Management Server SG
resource "aws_security_group" "mgt_main" {
  vpc_id                 = "${data.terraform_remote_state.networking.vpc_id}"
  description            = "ASCI Demo - Security Group to allow SSH access to the Management Server"
  revoke_rules_on_delete = false
}

# Management Server SG Rules
resource "aws_security_group_rule" "mgt_main" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.mgt_main.id}"
  description       = "Petrus Office"

  cidr_blocks = [
    "4.16.111.6/32",
    "72.220.105.66/32",
  ]
}

resource "aws_security_group_rule" "mgt_main-1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.mgt_main.id}"

  cidr_blocks = ["0.0.0.0/0"]
}
