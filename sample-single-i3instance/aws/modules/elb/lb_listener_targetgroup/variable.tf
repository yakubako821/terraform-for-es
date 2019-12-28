### Variables
variable "common_tags" {
  type = "map"
}

variable "lb" {}

variable "vpc_id" {}

variable "elb_listener_targetgroup_parameter" {
  type = "map"
}
