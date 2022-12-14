variable "vpc_id" {}
variable "vpc_zone_identifier" {}

resource "aws_security_group" "allow_http_to_frontend" {
  name        = "rds-demo-allow-http-to-alb"
  description = "Allow HTTP traffic to EC2 instances thr"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from self"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "frontend_asg" {
  name                                 = "frontend"
  image_id                             = "ami-00785f4835c6acf64"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t2.micro"
  vpc_security_group_ids               = [aws_security_group.allow_http_to_frontend.id]
  user_data                            = filebase64("${path.module}/userdata.sh")
  iam_instance_profile {
    name = aws_iam_instance_profile.allow_ec2_get_secrets_instance_profile.name
  }
}

resource "aws_autoscaling_group" "rds_frontend_autoscaling_group" {
  name                = "rds-frontend-asg"
  min_size            = 2
  max_size            = 2
  desired_capacity    = 2
  vpc_zone_identifier = var.vpc_zone_identifier
  target_group_arns   = [aws_lb_target_group.frontend_tg.id]

  launch_template {
    id      = aws_launch_template.frontend_asg.id
    version = "$Latest"
  }

}


resource "aws_lb" "frontend" {
  name               = "frontend"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_to_frontend.id]
  subnets            = var.vpc_zone_identifier
}

resource "aws_lb_target_group" "frontend_tg" {
  name     = "frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

resource "aws_iam_role" "allow_ec2_get_secrets_role" {
  name = "SSM-READ-RDS-PARAMETERS"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "allow_ec2_get_secrets_policy" {
  name        = "SSM-READ-RDS-PARAMETERS"
  description = "Policy to allow READ of all RDS parameters"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "SSMGetParams",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameterHistory",
                "ssm:GetParametersByPath",
                "ssm:GetParameters",
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:eu-west-2:*:parameter/rds/*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "allow_ec2_get_secrets_policy_attachment" {
  role       = aws_iam_role.allow_ec2_get_secrets_role.name
  policy_arn = aws_iam_policy.allow_ec2_get_secrets_policy.arn
}

resource "aws_iam_instance_profile" "allow_ec2_get_secrets_instance_profile" {
  name = "SSM-READ-RDS-PARAMS"
  role = aws_iam_role.allow_ec2_get_secrets_role.name
}

output "frontend_security_group" {
  value = aws_security_group.allow_http_to_frontend.id
}