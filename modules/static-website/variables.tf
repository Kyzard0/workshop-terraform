variable "bucket_name" {
}

variable "origin_id" {
}

variable "enabled" {
  type = bool
  default = true
}

variable "origin_path" {
  default = ""
}

variable "is_ipv6_enabled" {
  type = bool
  default = true
}
