


variable "aws_region" {
  type        = string
}

variable "environment" {
  type        = string
}

variable "az_count" {
  type        = string
}

variable "app_port" {
  type        = number
}

variable "health_check_path" {
  type        = string
}

variable "fargate_cpu" {
  type        = string
}

variable "fargate_memory" {
  type        = string
}

variable "vpc_id" {
  type        = string
}

variable "vpc_subnets" {
  type        = list(string)
}

variable "vpc_public_subnets" {
  type        = list(string)
}

variable "db_url_fa" {
  type        = string
}

variable "db_url_ro" {
  type        = string
}

variable "db_username" {
  type        = string
}

variable "db_password" {
  type        = string
}

variable "desired_containers" {
  type        = number
}

variable "minimum_containers" {
  type        = number
}

variable "maximum_containers" {
  type        = number
}
