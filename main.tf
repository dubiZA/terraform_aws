provider "aws" {
  region = "us-east-1"
  profile = "terraform"
}

resource "aws_instance" "example" {
  ami = "ami-07ebfd5b3428b6f4d"
  instance_type = "t2.micro"

  tags = {
      Name = "terraform-example"
  }
}
