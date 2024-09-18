resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "Allow SSH and other required traffic"

  # allow only incoming SSh traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # cidr_blocks = ["0.0.0.0/0"]
    # NOTE: only allow incoming traffic from this IP
    cidr_blocks = [ "${local.my_ipv4}/32" ]
    ipv6_cidr_blocks = [ "${local.my_ipv6}/128" ]
  }

  # allow all outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance_sg"
  }

  vpc_id = module.vpc.vpc_id
}


resource "aws_key_pair" "deployer" {
  key_name   = "my-key-pair"
  public_key = local.ssh_public_key
}


# see https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest
# see https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/blob/29230f956912d751a01a5694510f684754a93196/examples/complete/main.tf#L62
# connect via `ssh <user>@<ip-address>`, where <user>=ubuntu or ec2-user
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"

  create_iam_instance_profile = true
  iam_role_path = aws_iam_role.sagemaker_execution_role.path

  # NOTE: Pick AMI from https://eu-west-1.console.aws.amazon.com/ec2/home?region=eu-west-1#AMICatalog:
  # HERE: ubuntu 24 LTS (amazon linux 2023 proved difficult for docker)
  ami = "ami-03cc8375791cb8bcf"
  instance_type          = "t3.medium"
  subnet_id              = module.vpc.public_subnets[0]
  key_name               = aws_key_pair.deployer.key_name
  associate_public_ip_address = true
  vpc_security_group_ids     = [aws_security_group.instance_sg.id]

  # NOTE: changes in root_block_device are ignored!
  # see https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/blob/29230f956912d751a01a5694510f684754a93196/examples/complete/main.tf#L62
  root_block_device = [{
    volume_type = "gp3"  # Optional: General Purpose SSD (you can choose gp2, io1, etc.)
    volume_size = 100  # Set root volume size to 100 GB, otherwise disk space issues
  },]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
