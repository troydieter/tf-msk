resource "random_id" "rando" {
  byte_length = 2
}

resource "aws_iam_instance_profile" "MSKClientIAM_Profile" {
  name = "MSKClientIAM_profile-${random_id.rando.hex}"
  role = aws_iam_role.MSKClientIAM_Role.name
}

resource "aws_iam_role" "MSKClientIAM_Role" {
  name = "MSKClientIAM_Role-${random_id.rando.hex}"
  path = "/"


  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "MSK-client-IAM-role" {
  for_each   = var.mskclientiamattachments
  policy_arn = each.value
  role       = aws_iam_role.MSKClientIAM_Role.*.name
}

resource "aws_instance" "msk-client" {
  ami                    = var.msk_ami
  instance_type          = var.msk_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.MSKClientInstanceSG.id]
  user_data              = file("./kafka-client-msk.sh")
  subnet_id              = aws_subnet.private_subnet[1].id
  iam_instance_profile   = aws_iam_instance_profile.MSKClientIAM_Profile.name
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = 100
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = aws_kms_key.msk-kms-key.arn
  }

  tags = merge(
    local.common-tags,
    map(
      "Name", "msk-client-${random_id.rando.hex}"
    )
  )
}

output "IP" {
  value       = aws_instance.msk-client.private_ip
  description = "The private IP address of the msk-client deployed."
}
