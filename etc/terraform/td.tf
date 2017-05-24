provider "aws" {
  region					= "us-west-2"
}

# Create keypair
resource "aws_key_pair" "td_key" {
  key_name					= "td_key"
  public_key				= "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxlaSwJikLZk2WpYnUW73Sj5m4mlOlOuUyCGpFABe5xsYcVdhZv17JoY/HwviRhONFF36zAyjB59v+87krdXasUm/npv31w7w5BLE1PWtTyW5+YllMDyjS+I1yvbRPqf8Wc5LTlsbRuZQsdeqYDsPo7Tp0CTVkBZhwNSSGYu9uQFLr9+u09GX7sNfVtq+HluCHVmVUfqvxwUJy4YajfUs2UFrSOSrTNpzCED1yV/xQUYy16L85wiBA5OvKLl+NrVeIQB4Ed+WFdCKeiQp9GJReufVNYb8G7+yNChhv3IEDcSo1cW8G9p2pZAxSbvR+5Hy/9HTa31bSFxgRaoTot9Urw== td@td"
}


# Create self-signed certs (ACM)
resource "tls_private_key" "td" {
  algorithm					= "ECDSA"
  ecdsa_curve				= "P384"
}

resource "tls_self_signed_cert" "td" {
  key_algorithm				= "${tls_private_key.td.algorithm}"
  private_key_pem			= "${tls_private_key.td.private_key_pem}"

  validity_period_hours 	= 720

  allowed_uses = [
      "key_encipherment",
      "digital_signature",
      "server_auth",
      "client_auth"
  ]

  dns_names 				= ["td.com", "td.net"]

  subject {
      common_name			= "td.com"
      organization 			= "TD Test, Inc"
  }
}

# For example, this can be used to populate an AWS IAM server certificate.
resource "aws_iam_server_certificate" "td" {
  name						= "td_self_signed_cert"
  certificate_body 			= "${tls_self_signed_cert.td.cert_pem}"
  private_key      			= "${tls_private_key.td.private_key_pem}"
}

# Create security group for ELB
resource "aws_security_group" "allow_td" {
  name                      = "allow_td"
  description               = "ELB TD ingress/egress traffic"

  ingress {
    from_port               = 80
    to_port                 = 80
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
  }

  ingress {
    from_port               = 443
    to_port                 = 443
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
  }

  egress {
    from_port               = 8900
    to_port                 = 8900
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
  }

  tags {
    Name                    = "allow_td"
  }
}

# Create security group for instances
resource "aws_security_group" "allow_td_inst" {
  name                      = "allow_td_inst"
  description               = "Instance TD ingress/egress traffic"

  ingress {
    from_port               = 22
    to_port                 = 22
    protocol                = "tcp"
    cidr_blocks             = ["141.206.246.10/32", "70.95.193.0/32"]
  }

  ingress {
    from_port               = 8900
    to_port                 = 8900
    protocol                = "tcp"
    security_groups         = ["${aws_security_group.allow_td.id}"]
  }

  egress {
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
  }

  tags {
    Name                    = "allow_td_inst"
  }
}



# Create ELB
resource "aws_elb" "td-elb" {
  security_groups       	= ["${aws_security_group.allow_td.id}"]
  name						= "td-elb"
  availability_zones		= ["us-west-2a", "us-west-2b", "us-west-2c"]

  listener {
    instance_port			= 8900
	instance_protocol		= "http"
    lb_port					= 80
    lb_protocol				= "http"
  }

  listener {
    instance_port			= 8900
	instance_protocol		= "http"
    lb_port					= 443
    lb_protocol				= "https"
    ssl_certificate_id		= "${aws_iam_server_certificate.td.arn}"
  }

  health_check {
    healthy_threshold   	= 2
    unhealthy_threshold		= 2
    timeout					= 3
    target					= "HTTP:8900/"
    interval				= 30
  }

  instances					= ["${aws_instance.td-apache.*.id}", "${aws_instance.td-nginx.id}"]
}

# Create EC2 instances (apache)
resource "aws_instance" "td-apache" {
  count						= 2
  ami						= "ami-5e63d13e"
  instance_type				= "t2.micro"
  key_name					= "td_key"
  vpc_security_group_ids	= ["${aws_security_group.allow_td_inst.id}"]

  tags {
    Name 					= "td-apache-${count.index}"
  }
}

resource "null_resource" "configure-instance-ips" {
  count 					= 2

  provisioner "local-exec" {
    command 				= "sleep 120; ansible-playbook -u ubuntu -i '${element(aws_instance.td-apache.*.public_ip, count.index)},' /etc/ansible/td-apache.yml"
  }
}

# Create EC2 instance (nginx)
resource "aws_instance" "td-nginx" {
  ami                       = "ami-5e63d13e"
  instance_type             = "t2.micro"
  key_name                  = "td_key"
  vpc_security_group_ids    = ["${aws_security_group.allow_td_inst.id}"]

  tags {
    Name                    = "td-nginx-0"
  }

  provisioner "local-exec" {
    command 				= "sleep 120; ansible-playbook -u ubuntu -i '${aws_instance.td-nginx.public_ip},' /etc/ansible/td-nginx.yml"
  }
}
