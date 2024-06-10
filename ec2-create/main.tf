data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["amazon"]
}

resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "key_pair" {
    key_name = var.keyname
    public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "savekey" {
    content = tls_private_key.rsa.public_key_openssh
    filename = var.keypath
}

resource "aws_security_group" "allow_ssh" {
    name = var.sg_name
}

resource "aws_vpc_security_group_ingress_rule" "in_allow_ssh_ip" {
    security_group_id = aws_security_group.allow_ssh.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 22
    ip_protocol = "TCP"
    to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "eg_allow_all_traffic" {
    security_group_id = aws_security_group.allow_ssh.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = -1
}


resource "aws_instance" "create_ec2" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    key_name = aws_key_pair.key_pair.key_name
    tags = {
      name = "Terraform-ec2"
    }
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]
}