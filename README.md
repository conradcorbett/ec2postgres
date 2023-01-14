Example to show the use of modules.
Module create_vpc is a public module as shown by the source path
Module ec2vm is a local module as shown by the source path

ssh.tf creates a public/private key pair that can be used for the EC2 VM. The public key is provided when the VM is created by terraform. The private key is saved onto your local machine.