resource "random_string" "password" {
  length  = 10
  special = false
}

resource "aws_instance" "f5" {
  # F5 BIGIP-17.1.1.3-0.0.5 PAYG-Good 25Mbps
  ami = "ami-046a61b731e6de3a5"

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
