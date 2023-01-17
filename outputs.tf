output "output" {
  value = <<README

postgressvm: ssh -i ~/awskey.pem ubuntu@${module.ec2vm.public_ip}

README
}

output "environment" {
    value = var.environment
}