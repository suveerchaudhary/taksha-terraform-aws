# This is the main.tf file for the EC2 module which provides an EC2 instance

# Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"] #restricts the search to AMIs published by Amazon itself
  filter {
    name = "name"
    #pattern-matches against the AMI's name field. al2023-ami-*-x86_64 matches Amazon Linux 2023 images for x86_64 architecture
    # the * is a wildcard since the actual name includes a version/date string
    # never hardcode an AMI ID (which would go stale and differ per region anyway — AMI IDs are region-specific). 
    #Instead, this always resolves to "whatever the latest Amazon Linux 2023 image is, in us-west-2, right now.
    values = ["al2023-ami-*-x86_64"] # This is the name of the AMI to use
  }
}

#Security Group for SSH access - only allows SSH from your own IP
resource "aws_security_group" "ssh_access" {
  name   = "${var.environment}-ec2-sg"
  vpc_id = var.vpc_id

  #Ingress rule for SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }
  #Egress rule for all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.environment}-ec2-sg"
  }
}

#EC2 Instance
resource "aws_instance" "ec2_instance" {
  ami                     = data.aws_ami.amazon_linux.id
  instance_type           = var.instance_type
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = [aws_security_group.ssh_access.id]
  disable_api_termination = var.enable_termination_protection

  tags = { Name = "${var.environment}-web-server" }
}
