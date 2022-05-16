variable "myvpccidrblock" {
  type = string
  default = "10.0.0.0/16"
}

variable "mypubsubnetcidr" {
  type = string
  default = "10.1.0.0/24"
}

variable "pubaz" {

}

variable "myprivsubnetcidr" {
  type = string
  default = "10.2.0.0/24"
}

variable "privaz" {

}

variable "amiid" {
  type = string
  default = "abc18290-021"
}

variable "myinsttype" {
  type = string
  default = "t2.micro"
}
variable "mykey" {
  type = string
  default = "DevOpsKey"
}
