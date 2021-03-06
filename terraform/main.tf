provider "aws" {
  region     = "us-east-1"
  shared_credentials_file = "/Users/saad/.aws/credentials"

}

terraform {
  backend "s3" {
    bucket   = "saadtest-ifbi-terraform-state"
    key      = "poc-ecs"
    encrypt  = true
    region   = "us-east-1"
  }
}


data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

## ------------------------------------------------
## Create KMS Key
## ------------------------------------------------
resource "aws_kms_key" "kmsKey" {
  description = "POC KMS Key"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  policy = <<POLICY
    {
        "Version": "2012-10-17",
        "Id": "key-consolepolicy-3",
        "Statement": [
            {
                "Sid": "Allow CloudFront Flow Logs to use the key",
                "Effect": "Allow",
                "Principal": {
                    "Service": "delivery.logs.amazonaws.com"
                },
                "Action": "kms:GenerateDataKey*",
                "Resource": "*"
            },
            {
                "Sid": "Enable IAM User Permissions",
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
                },
                "Action": "kms:*",
                "Resource": "*"
            }
        ]
    }
    POLICY
}

resource "aws_kms_alias" "kmsAlias" {
  name          = "alias/poc-app-kms-key"
  target_key_id = aws_kms_key.kmsKey.key_id
}   

## ------------------------------------------------
## Setup Networking
## ------------------------------------------------
module "networking" {
  source = "./modules/networking"
  
  environment = var.environment

  vpcCIDR=var.vpcCIDR
  publicSubnet1CIDR=var.publicSubnet1CIDR
  publicSubnet2CIDR=var.publicSubnet2CIDR
  privateSubnet1CIDR=var.privateSubnet1CIDR
  privateSubnet2CIDR=var.privateSubnet2CIDR
  aws_region = "us-east-1"
  az_count = "2"

}

## ------------------------------------------------
## Setup Database
## ------------------------------------------------
module "database" {
  source                              = "./modules/database"

  name                                = "poc-aurora-rds-mysql"
  engine                              = "aurora"
  #engine_version                      = "5.6.mysql_aurora.1.22.2"
  subnets                             = [module.networking.private_subnet_1, module.networking.private_subnet_2]
  vpc_id                              = module.networking.vpc_id
  replica_count                       = 2
  instance_type                       = "db.t2.small"
  apply_immediately                   = true
  skip_final_snapshot                 = true
  db_parameter_group_name             = "default"
  db_cluster_parameter_group_name     = "default"
  iam_database_authentication_enabled = false
  enabled_cloudwatch_logs_exports     = ["audit", "error", "general", "slowquery"]
  allowed_cidr_blocks                 = [var.vpcCIDR]
  create_security_group = true
}

# ------------------------------------------------
# Setpup an ECR Repository
# ------------------------------------------------
module "ecr" {
  source = "./modules/ecr"
}

#------------------------------------------------
# Setup an ECS cluster
# ------------------------------------------------
module "ecs" {
  source = "./modules/ecs"

  environment = "poc"
  aws_region = var.awsRegion

  az_count = "2"
  vpc_id = module.networking.vpc_id
  vpc_subnets = [ module.networking.private_subnet_1,  module.networking.private_subnet_2 ]
  vpc_public_subnets = [ module.networking.public_subnet_1,  module.networking.public_subnet_2 ]
  
  ## must not be needed here
  ecr_repo_url = module.ecr.repo_url
  app_port = 80
  health_check_path = "/"
}

# ------------------------------------------------
# Setup ECS cluster
# ------------------------------------------------
module "poc-app" {
  source = "./poc_app"

  environment = "poc"
  aws_region = var.awsRegion

  ecs_cluster_name = module.ecs.cluster_name
  ecs_cluster_id = module.ecs.cluster_id
  ecr_repo_url = module.ecr.repo_url
  alb_listener_arn = module.ecs.alb_listener_arn
  target_group_arn = module.ecs.target_group_arn


  app_port = 80
  health_check_path = "/"
  fargate_cpu = "4096"
  fargate_memory = "8192"
  
  vpc_id = module.networking.vpc_id
  vpc_subnets = [ module.networking.private_subnet_1,  module.networking.private_subnet_2 ]
  vpc_public_subnets = [ module.networking.public_subnet_1,  module.networking.public_subnet_2 ]
  db_url_fa = module.database.this_rds_cluster_endpoint
  db_url_ro = module.database.this_rds_cluster_reader_endpoint 
  db_username = module.database.this_rds_cluster_master_username
  db_password = module.database.this_rds_cluster_master_password
  #Auto-Scaling Vars
  desired_containers = 0
  minimum_containers = 0
  maximum_containers = 0

  # must not be needed
  az_count = "2"
}


## ------------------------------------------------
## Output Section
## ------------------------------------------------
output "loadbalancer_url" {
  value = "${module.ecs.loadbalancer_url}"
}

output "ecr-repo" {
  value = "${module.ecr.repo_url}"
}

output "api_gateway_url" {
  value = "${module.poc-app.api_url}"
}

output "cloudfront_domain_name" {
  value = "${module.poc-app.cloudfront_domain_name}"
}
