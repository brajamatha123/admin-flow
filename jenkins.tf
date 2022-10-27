


resource "aws_security_group" "jenkins" {
  name        = "jenkins-sg"
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
    Name = "jenkins-sg"
  }
}






# to create instance



resource "aws_instance" "jenkins" {
  ami           = "ami-094bbd9e922dc515d"
  instance_type = "t2.micro"
  /* subnet_id     = "subnet-00c3688447700c3e1" */
  subnet_id     = aws_subnet.private[0].id
  key_name      = aws_key_pair.demo1.id

  vpc_security_group_ids = [aws_security_group.jenkins.id]
  /* iam_instance_profile   = aws_iam_instance_profile.artifactory.name */
  user_data              = <<EOF
 #!/bin/bash
 yum update -y
 sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
 sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
 yum install epel-release # repository that provides 'daemonize'
 amazon-linux-extras install epel
 amazon-linux-extras install java-openjdk11 -y
 yum install jenkins -y
 systemctl start jenkins
 systemctl enable jenkins
  EOF

  tags = {
    Name = "jenkinscicd"
  }
}
