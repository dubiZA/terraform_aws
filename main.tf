provider "aws" {
  region = "us-east-1"
  profile = "terraform"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id

}


variable "server_port" {
  description = "The port used by the infrastructure for HTTP requests"
  type = number
  default = 8080
}

resource "aws_launch_configuration" "example" {
  image_id = "ami-07ebfd5b3428b6f4d"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance.id]
  
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  
  # Required when using a launch config with an ASG.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "name" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = data.aws_subnet_ids.default.ids

  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform_asg_example"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}