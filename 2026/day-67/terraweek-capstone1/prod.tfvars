vpc_cidr      = "10.2.0.0/16"
subnet_cidr   = "10.2.1.0/24"
instance_type = "t2.small" # I used t2.small because t3.small is not working
ingress_ports = [80, 443]
