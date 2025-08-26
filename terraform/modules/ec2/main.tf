# EC2 Instance
resource "aws_instance" "ide" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile_name

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true

    tags = merge(var.common_tags, {
      Name = "${var.environment}-ide-volume"
    })
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = var.environment
  }))

  tags = merge(var.common_tags, {
    Name = "${var.environment}-ide-instance"
    Type = "eksworkshop-ide"
  })

  depends_on = [var.depends_on]
}
