# Create a VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Demo VPC"
  }
}

# Create Web Public Subnet
resource "aws_subnet" "web-subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = var.web_subnet_cidr[count.index]
  availability_zone       = var.availability_zone_names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Web-${count.index}"
  }
}

# Create Application Public Subnet
resource "aws_subnet" "application-subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = var.application_subnet_cidr[count.index]
  availability_zone       = var.availability_zone_names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "Application-${count.index}"
  }
}

# Create Database Private Subnet
resource "aws_subnet" "database-subnet" {
  count             = 2
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = var.database_subnet_cidr[count.index]
  availability_zone = var.availability_zone_names[count.index]

  tags = {
    Name = "Database-${count.index}"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "Demo IGW"
  }
}

# Create Web layber route table
resource "aws_route_table" "web-rt" {
  vpc_id = aws_vpc.my-vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "WebRT"
  }
}

# Create Web Subnet association with Web route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.web-subnet[0].id
  route_table_id = aws_route_table.web-rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.web-subnet[1].id
  route_table_id = aws_route_table.web-rt.id
}

#Create EC2 Instance
resource "aws_instance" "webserver" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.instance_type
  availability_zone      = var.availability_zone_names[count.index]
  vpc_security_group_ids = [aws_security_group.webserver-sg.id]
  subnet_id              = aws_subnet.web-subnet[count.index].id
  user_data              = file("install_apache.sh")

  tags = {
    Name = "Web Server"
  }

}

# resource "aws_instance" "webserver2" {
#   ami                    = var.ami_id
#   instance_type          = var.instance_type
#   availability_zone      = var.availability_zone_names[1]
#   vpc_security_group_ids = [aws_security_group.webserver-sg.id]
#   subnet_id              = aws_subnet.web-subnet[1].id
#   user_data              = file("install_apache.sh")

#   tags = {
#     Name = "Web Server"
#   }
# }

# Create Web Security Group
resource "aws_security_group" "web-sg" {
  name        = "Web-SG"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-SG"
  }
}

# Create Application Security Group
resource "aws_security_group" "webserver-sg" {
  name        = "Webserver-SG"
  description = "Allow inbound traffic from ALB"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description     = "Allow traffic from web layer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Webserver-SG"
  }
}

# Create Database Security Group
# resource "aws_security_group" "database-sg" {
#   name        = "Database-SG"
#   description = "Allow inbound traffic from application layer"
#   vpc_id      = aws_vpc.my-vpc.id

#   ingress {
#     description     = "Allow traffic from application layer"
#     from_port       = 3306
#     to_port         = 3306
#     protocol        = "tcp"
#     security_groups = [aws_security_group.webserver-sg.id]
#   }

#   egress {
#     from_port   = 32768
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "Database-SG"
#   }
# }

resource "aws_lb" "external-elb" {
  name               = "External-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-sg.id]
  subnets            = [aws_subnet.web-subnet[0].id, aws_subnet.web-subnet[1].id]
}

resource "aws_lb_target_group" "external-elb" {
  name     = "ALB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my-vpc.id
}

resource "aws_lb_target_group_attachment" "external-elb1" {
  target_group_arn = aws_lb_target_group.external-elb.arn
  target_id        = aws_instance.webserver[0].id
  port             = 80

  depends_on = [
    aws_instance.webserver[0],
  ]
}

resource "aws_lb_target_group_attachment" "external-elb2" {
  target_group_arn = aws_lb_target_group.external-elb.arn
  target_id        = aws_instance.webserver[1].id
  port             = 80

  depends_on = [
    aws_instance.webserver[1],
  ]
}

resource "aws_lb_listener" "external-elb" {
  load_balancer_arn = aws_lb.external-elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external-elb.arn
  }
}

# resource "aws_db_instance" "default" {
#   allocated_storage      = 10
#   db_subnet_group_name   = aws_db_subnet_group.default.id
#   engine                 = "mysql"
#   engine_version         = "8.0.20"
#   instance_class         = "db.t2.micro"
#   multi_az               = false
#   name                   = "mydb"
#   username               = "username"
#   password               = "password"
#   skip_final_snapshot    = true
#   vpc_security_group_ids = [aws_security_group.database-sg.id]
# }

# resource "aws_db_subnet_group" "default" {
#   name       = "main"
#   subnet_ids = [aws_subnet.database-subnet-1.id, aws_subnet.database-subnet-2.id]

#   tags = {
#     Name = "My DB subnet group"
#   }
# }