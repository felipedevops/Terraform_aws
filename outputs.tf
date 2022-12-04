output "security_group_public" {
  value = aws_security_group.public.id
}

 

output "security_group_private" {
  value = aws_security_group.private.id
}

output "lambda" {
  value = aws_lambda_function.func.qualified_arn
}

output "timestamp" {
  value = "${local.timestamp_sanitized}"
}


output "availability_zone_1" {
  value = data.aws_availability_zones.available.names[0]
}