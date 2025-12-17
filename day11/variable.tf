variable "project_name" {
    type        = string
    description = "The name of the project"
    default     = "Project ALPHA Resource"
}
variable "default_tags" {
    type = map(string)
    default = {
        company    = "TechCorp"
        managed_by = "terraform"
    }
}

variable "env_tags" {
    type = map(string)
    default = {
        environment  = "production"
        cost_center = "cc-123"
    }
}

variable "storage_account_name" {
    type        = string
    default     = "Techtutorial with p!1yush"
}

variable "allowed_ports" {
    type        = string
    description = "List of ports to be used"
    default     = "80,443,8080,3306"
}