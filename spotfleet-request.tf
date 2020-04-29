resource "aws_security_group" "asg_sg" {
  name   = "asg_sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allow_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allow_cidr_block]
  }
}

resource "aws_iam_role" "instance_role" {
  name = "instance_role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance_profile"
  path = "/"
  role = aws_iam_role.instance_role.name
}
resource "aws_iam_role_policy_attachment" "ec2_admin_role" {
  role       = aws_iam_role.instance_role.id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Request a Spot fleet
resource "aws_iam_role" "spotfleet_role" {
  name = "spotfleet-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "spotfleet.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonEC2SpotFleetTaggingRole-policy-attachment" {
  role = aws_iam_role.spotfleet_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.user_data.rendered
  }
}

# resource "aws_spot_fleet_request" "spotfleet_request" {
#   iam_fleet_role      = aws_iam_role.spotfleet_role.arn
#   allocation_strategy = "lowestPrice"
#   target_capaci           ty     = 1
#   terminate_instances_with_expiration = true

#   launch_specification {
#     instance_type            = var.instance_type
#     ami                      = var.aws_ami
#     key_name                 = var.key_name
#     iam_instance_profile_arn = aws_iam_instance_profile.instance_profile.arn
#     subnet_id                = element(module.vpc.public_subnets,0)
#     user_data                = data.template_cloudinit_config.config.rendered
#     vpc_security_group_ids   = [aws_security_group.asg_sg.id]
#     tags = {
#       Name = "spot-fleet"
#     }
#   }
# }

resource "aws_spot_instance_request" "ec2-instance" {
  ami                   = var.aws_ami
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.asg_sg.id]
  user_data                   = data.template_file.user_data.rendered
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.id
  subnet_id                   = element(module.vpc.public_subnets,0)
  key_name                    = var.key_name
  associate_public_ip_address = true
  wait_for_fulfillment = true
  spot_type = "one-time"

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

}