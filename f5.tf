resource "random_string" "password" {
  length  = 10
  special = false
}

resource "aws_instance" "f5" {
  # F5 BIGIP-14.1.0.3-0.0.6 PAYG-Good 25Mbps-190326002717
  ami = "ami-00a9fd893d5d15cf6"

  instance_type               = "m5.xlarge"
  private_ip                  = "10.0.0.200"
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.f5.id]
  user_data                   = templatefile("${path.module}/templates/f5.tpl", { password = random_string.password.result })
  key_name                    = aws_key_pair.demo.key_name
  root_block_device {
    delete_on_termination = true
  }

  tags = {
    Name = "${var.prefix}-f5"
    Env  = "vault"
  }
}
