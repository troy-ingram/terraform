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