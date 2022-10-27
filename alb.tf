resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Allow all end users"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "allow end users"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_lb" "uma-test-alb" {
  name               = "uma-test-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets       = [aws_subnet.public[0].id, aws_subnet.public[1].id]
  /* subnets            = ["subnet-0f957a91835d9febe","subnet-0b4c5d675ba3aaa76"] */

#   enable_deletion_protection = true

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.bucket
#     prefix  = "test-lb"
#     enabled = true
#   }

  tags = {
    Environment = "uma-alb"
  }
}

resource "aws_lb_target_group" "uma-tg-jenkins" {
  name     = "tg-jenkins"
  port     = 8080
  protocol = "HTTP"
  /* vpc_id   = "vpc-0b8a10a9f3969a588" */
   vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "uma-tg-attachment-jenkins" {
  target_group_arn = aws_lb_target_group.uma-tg-jenkins.arn
  target_id        = aws_instance.jenkins.id
  port             = 8080
}


resource "aws_lb_target_group" "uma-tg-tomcat" {
  name     = "tg-tomcat"
  port     = 8080
  protocol = "HTTP"
  /* vpc_id   = "vpc-0b8a10a9f3969a588" */
   vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "uma-tg-attachment-tomcat" {
  target_group_arn = aws_lb_target_group.uma-tg-tomcat.arn
  target_id        = aws_instance.tomcat.id
  port             = 8080
}


resource "aws_lb_listener" "uma-alb-listener" {
  load_balancer_arn = aws_lb.uma-test-alb.arn
  port              = "80"
  protocol          = "HTTP"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.uma-tg-jenkins.arn
  }
}

resource "aws_lb_listener_rule" "uma-jenkins-hostbased" {
  listener_arn = aws_lb_listener.uma-alb-listener.arn
#   priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.uma-tg-jenkins.arn
  }

  condition {
    host_header {
      values = ["jenkins.uma.quest"]
    }
  }
}

resource "aws_lb_listener_rule" "uma-tomcat-hostbased" {
  listener_arn = aws_lb_listener.uma-alb-listener.arn
#   priority     = 98

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.uma-tg-tomcat.arn
  }

  condition {
    host_header {
      values = ["tomcat.uma.quest"]
    }
  }
}
































