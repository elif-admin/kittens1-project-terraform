terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "sg" {
  name = "ssh_http_sec"

  ingress {
    description      = "Http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

   ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
  from_port = 0
  protocol = "-1"
  to_port = 0
  cidr_blocks      = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "kitten" {
  ami           =  "ami-006dcf34c09e50022" 
  instance_type = "t2.micro"
  key_name = "first-key"
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = "Kitten"
  }
  
   #user_data = "${file("userdata.sh")}"

  user_data = <<EOF
    #! /bin/bash
    yum update -y
    yum -y install wget
    yum install httpd -y
    FOLDER="https://raw.githubusercontent.com/elif-admin/Kittens1-project/main/static-web"
    cd /var/www/html
    wget $FOLDER/index.html
    wget $FOLDER/cat0.jpg
    wget $FOLDER/cat1.jpg
    wget $FOLDER/cat2.jpg
    wget $FOLDER/cat3.png
    systemctl start httpd
    systemctl enable httpd
  EOF
}


output "kittenpublicip" {
  value = aws_instance.kitten.public_ip
}






