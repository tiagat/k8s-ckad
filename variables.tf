variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "aws_cidr_block" {
  default = "10.1.1.0/24"
}

variable "aws_subnet_public" {
  
  default = "10.1.1.0/28"

  # Network:   10.1.1.0/28
  # Broadcast: 10.1.1.15
  # HostMin:   10.1.1.1
  # HostMax:   10.1.1.14
  # Hosts/Net: 14
}

variable "aws_subnet_private" {
  
  default = "10.1.1.16/28"

  # Network:   10.1.1.16/28
  # Broadcast: 10.1.1.31
  # HostMin:   10.1.1.17
  # HostMax:   10.1.1.30
  # Hosts/Net: 14

}
