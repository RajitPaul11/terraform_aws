variable "instance_type" {
  default = {
    "prod" = "m5.large"
    "dev" = "t3.large"
  }
  type = map
}