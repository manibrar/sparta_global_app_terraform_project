provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "main_vpc" {
  cidr_block       = "10.10.0.0/16"
  tags {
    Name = "app-vpc"
  }
}




    # APP
resource "aws_route_table" "app_route_table" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.app_intenet_gateway.id}"
  }

  tags {
    Name = "app-route-table"
  }
}

resource "aws_route_table_association" "app_route_association" {
  subnet_id      = "${aws_subnet.app_subnet.id}"
  route_table_id = "${aws_route_table.app_route_table.id}"
}

resource "aws_internet_gateway" "app_intenet_gateway" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  tags {
    Name = "main"
  }
}

data "template_file" "app_user_data" {
  template = "${file("${path.module}/templates/app/user_data.sh.tpl")}"

}

resource "aws_subnet" "app_subnet" {
  vpc_id     = "${aws_vpc.main_vpc.id}"
  cidr_block = "10.10.1.0/24"
  availability_zone = "eu-west-1a"
  tags {
    Name = "subnet-app-manvir"
  }
}

resource "aws_security_group" "app_sg_manvir" {
  name        = "app-sg-manvir"
  description = "security group for app"
  vpc_id      = "${aws_vpc.main_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_instance_1a" {
  ami = "ami-c2b8bfbb"
  instance_type = "t2.micro"
  user_data = "${data.template_file.app_user_data.rendered}"
  subnet_id = "${aws_subnet.app_subnet.id}"
  security_groups = ["${aws_security_group.app_sg_manvir.id}"]
  associate_public_ip_address = true
  tags {
    Name = "app-instance-1a"
  }
}
