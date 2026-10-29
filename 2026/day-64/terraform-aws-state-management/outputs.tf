output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.my_instance[*].public_ip # this is Interpolation (Extracting something from a very big output)
}