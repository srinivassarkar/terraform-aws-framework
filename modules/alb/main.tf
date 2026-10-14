resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(
    var.tags,
    {
      Name        = var.name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_lb_target_group" "this" {
  name     = "${var.name}-tg"
  port     = var.target_port
  protocol = var.target_protocol
  vpc_id   = var.vpc_id

  target_type          = "instance"
  deregistration_delay = var.deregistration_delay

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = var.target_protocol
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    matcher             = var.health_check_matcher
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-tg"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = toset(var.target_instance_ids)

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = each.value
  port             = var.target_port
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
