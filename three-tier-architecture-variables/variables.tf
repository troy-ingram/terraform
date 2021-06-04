#Count variable
variable "item_count" {
  description = "default count used to set AZs and instances"
  type        = number
  default     = 2
}

#VPC variables
variable "vpc_cidr" {
  description = "default vpc cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone_names" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "web_subnet_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "application_subnet_cidr" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "database_subnet_cidr" {
  type    = list(string)
  default = ["10.0.21.0/24", "10.0.22.0/24"]
}

#Instance variables
variable "ami_id" {
  description = "default ami"
  type        = string
  default     = "ami-0d5eff06f840b45e9"
}

variable "instance_type" {
  description = "default instance type"
  type        = string
  default     = "t2.micro"
}

#Create database variables
variable "rds_instance" {
  type = map(any)
  default = {
    allocated_storage   = 10
    engine              = "mysql"
    engine_version      = "8.0.20"
    instance_class      = "db.t2.micro"
    multi_az            = false
    name                = "mydb"
    skip_final_snapshot = true
  }
}

#Create database sensitive variables
variable "user_information" {
  type = map(any)
  default = {
    username = "username"
    password = "password"
  }
  sensitive = true
}