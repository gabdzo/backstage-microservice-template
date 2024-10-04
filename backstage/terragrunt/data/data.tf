data "aws_availability_zones" "available" {}

output az_names {
  value       = data.aws_availability_zones.available.names
  description = "Return list of available AZs"
}
