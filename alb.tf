# 1. Target Group
resource "aws_lb_target_group" "web_tg" {
  name     = "tg-web-producao"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# 2. Application Load Balancer
resource "aws_lb" "web_alb" {
  name               = "alb-web-producao"
  internal           = false 
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  
  # OBRIGATÓRIO: Pelo menos duas subnets em AZs diferentes
  subnets = [
    aws_subnet.public_1a.id, 
    aws_subnet.public_1b.id
  ] 
}

# 3. Listener
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}