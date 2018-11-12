# ACM - Certificate for app/site
resource "aws_acm_certificate" "main" {
  domain_name       = "poorsignal.com"
  validation_method = "EMAIL"

  subject_alternative_names = [
    "*.poorsignal.com",
  ]

  tags {
    Name = "poorsignal.com"
  }
}

# Get AWS 2 AMI
data "aws_ami" "amz" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-2018*"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# AWS Launch Config
resource "aws_launch_configuration" "app_main" {
  name_prefix          = "ASCI Demo - App Servers Launch Config"
  image_id             = "${data.aws_ami.amz.id}"
  instance_type        = "t2.micro"
  iam_instance_profile = "${module.app_role.instance_profile_name}"
  key_name             = "${aws_key_pair.app_main.id}"
  enable_monitoring    = false

  security_groups = [
    "${aws_security_group.app_main.id}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  max_size                  = 1
  min_size                  = 1
  desired_capacity          = 1
  force_delete              = false
  metrics_granularity       = "1Minute"
  wait_for_capacity_timeout = "10m"
  launch_configuration      = "${aws_launch_configuration.app_main.name}"
  target_group_arns         = ["${aws_lb_target_group.main.arn}"]
  vpc_zone_identifier       = ["${data.terraform_remote_state.networking.private_subnets}"]

  lifecycle {
    create_before_destroy = true
  }
}

# Application Load Balancer
resource "aws_alb" "main" {
  name               = "asci-demo-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb_main.id}"]
  subnets            = ["${data.terraform_remote_state.networking.public_subnets}"]
}

# HTTPS Listener
resource "aws_lb_listener" "app_https" {
  load_balancer_arn = "${aws_alb.main.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate.main.arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.main.arn}"
    type             = "forward"
  }
}

# HTTP Listener
resource "aws_lb_listener" "app_http" {
  load_balancer_arn = "${aws_alb.main.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.main.arn}"
    type             = "forward"
  }
}

# Target Group
resource "aws_lb_target_group" "main" {
  port              = 443
  protocol          = "HTTPS"
  vpc_id            = "${data.terraform_remote_state.networking.vpc_id}"
  proxy_protocol_v2 = false
}
