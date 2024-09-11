
variable "assign_generated_ipv6_cidr_block" {
  type    = bool
  default = true
}
variable "availability_zones" {
  description = <<EOF
  The availability zones (azs) within a region where you want subnets placed. At least one
  az must have `nat_gateway_enabled` set to `true`.
  EOF
  type = map(object({
    nat_gateway_enabled            = bool
    public_route_table_enabled     = bool
    public_route_table_association = string
  }))
  default = {}
}

variable "enable_dns64" {
  description = "Enables dns64 if IPv6 is being used"
  default     = true
}
variable "enable_dns_hostnames" { default = true }
variable "enable_dns_support" { default = true }
variable "instance_tenancy" { default = "default" }
variable "env" { default = "development" }
variable "ipv4" {
  type = object({
    bits                                        = number
    cidr_block                                  = string
    destination_cidr_block                      = string
    enable_resource_name_dns_a_record_on_launch = bool
  })
  default = null
}
variable "ipv6" {
  description = "Configs for supporting IPv6 in the VPC"
  type = object({
    bits                                           = number
    assign_ipv6_address_on_creation                = bool
    destination_cidr_block                         = string
    enabled                                        = bool
    enable_dns64                                   = bool
    enable_resource_name_dns_aaaa_record_on_launch = bool
  })
  default = null
}

variable "private_dns_hostname_type_on_launch" { default = "ip-name" }
variable "region" {
  description = "The region the VPC is being created in"
}
variable "region_code" {
  description = "AWS abbreviation for the region the VPC is being created in"
}
variable "subnet_tags" {
  description = "Additional tags to apply to each subnet"
  default = {
    private = {
      "cpco.io/subnet/type" = "private"
    }
    public = {
      "cpco.io/subnet/type" = "public"
    }
  }
}
