provider "aws" {
  region = "us-east-1"
}

# ----- Security Group, Inbound, Outbound rules -----
resource "aws_security_group" "devops_security_group" {
  description = "launch-wizard-1 created 2024-08-23T10:31:58.701Z"
  name        = "launch-wizard-1"
  vpc_id      = aws_vpc.cat_vpc.id
}

resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.devops_security_group.id
}

resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.devops_security_group.id
}

resource "aws_security_group_rule" "default_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.devops_security_group.id
}

# ----- EC2 instance -----
resource "aws_instance" "my_instance" {

  ami                    = "ami-0e86e20dae9224db8"
  instance_type          = "t2.micro"
  key_name               = "test_devops"
  subnet_id              = aws_subnet.cat_subnet.id
  vpc_security_group_ids = [aws_security_group.devops_security_group.id]

  security_groups = [
    aws_security_group.devops_security_group.name,
  ]

  source_dest_check = true

  tags = {
    "Name" = "test_devops"
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  cpu_options {
    core_count       = 1
    threads_per_core = 1
  }

  credit_specification {
    cpu_credits = "standard"
  }

  enclave_options {
    enabled = false
  }

  maintenance_options {
    auto_recovery = "default"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
    instance_metadata_tags      = "disabled"
  }

  private_dns_name_options {
    enable_resource_name_dns_a_record    = true
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }

  root_block_device {
    delete_on_termination = true
    iops                  = 3000
    throughput            = 125
    volume_size           = 8
    volume_type           = "gp3"
  }
}

# ----- S3 buckets, encryption_configuration, versioning -----

resource "aws_s3_bucket" "cats_bucket" {
  bucket = "devops-random-cats"
}

resource "aws_s3_bucket_versioning" "cats_bucket_versioning" {
  bucket = "devops-random-cats"

  versioning_configuration {
    status = "Disabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "cats_bucket_encryption" {
  bucket = aws_s3_bucket.cats_bucket.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
      kms_master_key_id = null
    }
  }
}

resource "aws_s3_bucket_acl" "cat_bucket_acl" {
  bucket = "devops-random-cats"

  access_control_policy {
    grant {
      permission = "FULL_CONTROL"

      grantee {
        id   = "1d56aeaa9b88ca08088efdec1f59195c7bbcda4b0a60a4412cca3bb45488565a"
        type = "CanonicalUser"
      }
    }
    owner {
      display_name = "alesyavaskovith"
      id           = "1d56aeaa9b88ca08088efdec1f59195c7bbcda4b0a60a4412cca3bb45488565a"
    }
  }
}

# ----- Second Bucket -----

resource "aws_s3_bucket" "terraform_bucket" {
  bucket = "backup-bucket-tf"
}

resource "aws_s3_bucket_versioning" "terraform_versioning" {
  bucket = "backup-bucket-tf"

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_bucket_encryption" {
  bucket = aws_s3_bucket.terraform_bucket.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
      kms_master_key_id = null
    }
  }
}

resource "aws_s3_bucket_acl" "terraform_bucket_acl" {
  bucket = "backup-bucket-tf"

  access_control_policy {
    grant {
      permission = "FULL_CONTROL"

      grantee {
        id   = "1d56aeaa9b88ca08088efdec1f59195c7bbcda4b0a60a4412cca3bb45488565a"
        type = "CanonicalUser"
      }
    }
    owner {
      display_name = "alesyavaskovith"
      id           = "1d56aeaa9b88ca08088efdec1f59195c7bbcda4b0a60a4412cca3bb45488565a"
    }
  }
}


# ----- ECR repository -----
resource "aws_ecr_repository" "cat_container_repo" {

  image_tag_mutability = "MUTABLE"
  name                 = "devops-kitty-cat"

  encryption_configuration {
    encryption_type = "AES256"
    kms_key         = null
  }

  image_scanning_configuration {
    scan_on_push = false
  }
}

# ----- VPC -----
resource "aws_vpc" "cat_vpc" {
  assign_generated_ipv6_cidr_block     = false
  cidr_block                           = "172.31.0.0/16"
  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  enable_network_address_usage_metrics = false
  instance_tenancy                     = "default"
}

# ----- Subnet -----
resource "aws_subnet" "cat_subnet" {
  availability_zone_id                = "use1-az2"
  cidr_block                          = "172.31.80.0/20"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id                              = aws_vpc.cat_vpc.id
}


