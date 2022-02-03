variable "key_name" {
  default = "terraform-var-key"
  description = "Key Pair Name"
  type = string
  validation {
    condition = substr(var.key_name, 0, 9) == "terraform"
    error_message = "AWS Key pair name must start with terraform."
  }
}