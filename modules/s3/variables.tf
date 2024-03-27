variable "domain_name" {
  description = "Name of your domain"
  type        = string
}

variable "upload_template" {
  description = "Toggle pushing the given file (modify the template in /modules/s3.tf)"
  type        = bool
  default     = false
}