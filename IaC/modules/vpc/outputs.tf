output "vpc_id" {
  value = aws_vpc.demo_vpc.id
}

output "private_subnet_db" {
  value = aws_subnet.private_db[*].id
}

output "private_subnet_app" {
  value = aws_subnet.private_app[*].id
}

output "public_subnet" {
  value = aws_subnet.public[*].id
}