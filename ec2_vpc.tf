resource "aws_key_pair" "key" {
  key_name = "terra-key"
  public_key = file("/home/ubuntu/.ssh/terra-key.pub")
}
resource "aws_default_vpc" "default_vpc" {

}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"

  # using default VPC
  vpc_id      = aws_default_vpc.default_vpc.id
  ingress {
    description = "TLS from VPC"

    # we should allow incoming and outoging
    # TCP packets
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    # allow all traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

variable "ami_id" {
  description = "this is ubuntu ami id"
  default     = "ami-053b0d53c279acc90"
}

variable "tags" {
  type = map(string)
  default = {
    "name" = "Bharat's ec2"
  }
}

resource "aws_instance" "my_ec2" {
  ami             = var.ami_id
  instance_type   = "t2.micro"

  # refering key which we created earlier
  key_name        = aws_key_pair.key.key_name

  # refering security group created earlier
  security_groups = [aws_security_group.allow_ssh.name]

  tags = var.tags
}

output "arn" {
  value = aws_instance.my_ec2.arn
}

output "public_ip" {
  value = aws_instance.my_ec2.public_ip
}

# S3 Bucket Creation
resource "aws_s3_bucket" "my_bucket" {
  bucket = "bharat-terraform-bucket"
  acl    = "private" # Set bucket ACL to private

  tags = {
    Name        = "Bharat S3 bucket"
    Environment = "Dev"
  }
}

# S3 Bucket Outputs
output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.my_bucket.arn
}
