resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb_target_group" "alb_target_group" {
  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    port                = "traffic-port"
  }
}


resource "aws_alb" "alb" {
  idle_timeout    = 60
  internal        = false
  name            = "alb"
  security_groups = [aws_security_group.alb_sg.id]
  subnets         = module.vpc.public_subnets

  enable_deletion_protection = false

}

resource "aws_alb_listener" "alb_listener_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group.arn
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "listener_rule" {
  depends_on   = [aws_alb_target_group.alb_target_group]
  listener_arn = aws_alb_listener.alb_listener_http.arn
  action {    
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group.id  
  }   
  condition {
    path_pattern {
    values = ["/"]
    }
  }
}
# wait 2 minutes until the instance to be successfully running, then create attachment.
resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 120"
  }
  triggers = {
    "before" = "${aws_spot_instance_request.ec2-instance.id}"
  }
}

resource "aws_lb_target_group_attachment" "target_group_attach" {
  target_group_arn = aws_alb_target_group.alb_target_group.arn
  target_id        = aws_spot_instance_request.ec2-instance.spot_instance_id
  port             = 3000
  depends_on = [null_resource.delay]
}