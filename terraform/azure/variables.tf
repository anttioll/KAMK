variable "resource_group_location" {
  type        = string
  default     = "swedencentral"
  description = "Location of the resource group."
}

variable "identifier" {
  type        = string
  description = "ident var"
}

variable "myapp" {
  type        = string
  description = "nextcloud var"
  default     = "nextcloud"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags that are applied to all resources"
  default = {
    Owner       = "KAMK"
    Environment = "student"
    CostCenter  = "1020"
    Course      = "TT00CB27-3002"
  }
}
