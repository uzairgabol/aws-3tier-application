resource "aws_instance" "instance" {
  ami           = "ami-0e2c8caa4b6378d8c"
  instance_type = "t2.micro"
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [var.sg_id]
  iam_instance_profile   = var.iam_role_name
  associate_public_ip_address = false

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  # Modify user_data to include logging
  user_data = base64encode(<<-EOF
    #!/bin/bash
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
    echo "[$(date)] Starting user data script execution"
    ${file("${path.module}/scripts/${var.user_data_script}")}
    echo "[$(date)] Finished user data script execution"
  EOF
  )

  tags = {
    Name = var.instance_name
  }

  depends_on = [var.depends_on_resource]

  # Wait for instance to be ready and cloud-init to complete
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${self.id} --region us-east-1"
  }
}