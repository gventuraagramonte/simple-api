variable "awsprops" {
  type = map(any)
  default = {
    region       = "us-east-1"
    vpc          = "vpc-0870a91879f2b8d8f"
    ami          = "ami-09040d770ffe2224f"
    itype        = "t2.micro"
    subnet       = "subnet-0b6a5066daea462ec"
    publicip     = true
    keyname      = "cerberus"
    secgroupname = "cerberus"
  }
}

resource "aws_security_group" "prod-sec-sg" {
  name = var.instance_secgroupname
  vpc_id = var.instance_vpc_id

  // Habilitamos SSH
  dynamic "ingress" {

    for_each = var.ingress_rules
    content {
      from_port = lookup(ingress.value, "from_port",null)
      to_port = lookup(ingress.value, "to_port",null)
      protocol    = lookup(ingress.value, "protocol", null)
      cidr_blocks = lookup(ingress.value, "cidr_blocks", null)
    }
  }

  tags = {
    Name = "allow_tls"
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_instance" "project-iac-2" {
  ami                         = lookup(var.awsprops, "ami")
  instance_type               = lookup(var.awsprops, "itype")
  subnet_id                   = lookup(var.awsprops, "subnet")
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name                    = lookup(var.awsprops, "keyname")

  vpc_security_group_ids = [
    aws_security_group.prod-sec-sg.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 40
    volume_type = "gp2"
  }
  tags = {
    "Name"="cerberus"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "vd"
  }
  provisioner "file" {
    source = "installer.sh"
    destination = "/tmp/installer.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
        "sudo chmod +x /tmp/installer.sh",
        "sh /tmp/installer.sh"
     ]
  }
  depends_on = [ aws_security_group.prod-sec-sg ]

  connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    private_key = file("./cerberus.pem")
  }
}

output "ec2instance" {
  value = aws_instance.project-iac-2.public_ip
}