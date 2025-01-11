resource "aws_iam_role" "demo_ec2_role" {
  name = "Demo-EC2-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "demo-ec2-profile"
  role = aws_iam_role.demo_ec2_role.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.demo_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "rds_full" {
  role       = aws_iam_role.demo_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess"
}

resource "aws_iam_role_policy_attachment" "quicksight" {
  role       = aws_iam_role.demo_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSQuickSightDescribeRDS"
}

resource "aws_iam_role_policy_attachment" "elb_readonly" {
  role       = aws_iam_role.demo_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingReadOnly"
}