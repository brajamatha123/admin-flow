resource "aws_security_group" "tomcat" {
  name        = "tomcat-sg"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "allow ssh "
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]

  }
  ingress {
    description     = "allow alb"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]

  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "tomcat-sg"
  }
}




# to create tomcat instance

resource "aws_instance" "tomcat" {
  ami                    = "ami-094bbd9e922dc515d"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private[0].id
  key_name               = aws_key_pair.demo1.id
  vpc_security_group_ids = [aws_security_group.tomcat.id]
  user_data              = <<-EOF
 
 #!/bin/bash
 yum update -y
 amazon-linux-extras install java-openjdk11 -y
 wget -O /opt/apache-tomcat-9.0.65-windows-x64.zip / https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.65/bin/apache-tomcat-9.0.65-windows-x64.zip
 cd /opt
 ls -ltrh
 unzip apache-tomcat-9.0.65-windows-x64.zip
 apache-tomcat-9.0.65 tomcat9
 cd tomcat9/bin
 ls -ltrh *.sh
 chmod 755 *.sh
 sh startup.sh
  EOF
  tags = {
    Name = "tomcat"
  }
}