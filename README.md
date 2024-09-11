# terraform-aws-vpc

Creates a VPC for a region along with public and private subnets for each availability zone specified within the region.

**Example**

```hcp
locals {
  configs = {
    env         = "test"
    region      = "us-east-2"
    region_code = "use2"
  }
  azs = {
    us-east-1a = {
      nat_gateway_enabled = true
    }
    us-east-1b = {
      nat_gateway_enabled = true
    }
    us-east-1c = {
      nat_gateway_enabled = false
    }
  }
  ipv4 = {
    bits                                        = 4
    cidr_block                                  = local.configs.vpc_cidr
    destination_cidr_block                      = "0.0.0.0/0"
    enable_resource_name_dns_a_record_on_launch = true
  }
  ipv6 = {
    bits                                           = 8
    assign_ipv6_address_on_creation                = false
    destination_cidr_block                         = "64:ff9b::/96"
    enable_dns64                                   = false
    enable_resource_name_dns_aaaa_record_on_launch = true
  }
  subnet_tags = {
    public = {
      "kubernetes.io/cluster/test-use2" = "owned"
      "kubernetes.io/role/elb"          = "1"
    }
    private = {
      "kubernetes.io/cluster/test-use2" = "owned"
      "kubernetes.io/role/internal-elb" = "1"
    }
  }
}

module "network" {
  source  = ""
  version = "0.1.6"

  assign_generated_ipv6_cidr_block = false
  availability_zones               = local.azs
  ipv4                             = local.ipv4
  ipv6                             = local.ipv6
  env                              = local.configs.env
  region                           = local.configs.region
  region_code                      = local.configs.region_code
  subnet_tags                      = local.subnet_tags
}
```


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_egress_only_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/egress_only_internet_gateway) | resource |
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_rule.private4_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private4_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private6_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private6_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public4_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public4_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public6_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public6_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_route.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_nat64](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zone) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assign_generated_ipv6_cidr_block"></a> [assign\_generated\_ipv6\_cidr\_block](#input\_assign\_generated\_ipv6\_cidr\_block) | n/a | `bool` | `true` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | The availability zones (azs) within a region where you want subnets placed. At least one<br>  az must have `nat_gateway_enabled` set to `true`. | <pre>map(object({<br>    nat_gateway_enabled            = bool<br>    public_route_table_enabled     = bool<br>    public_route_table_association = string<br>  }))</pre> | `{}` | no |
| <a name="input_enable_dns64"></a> [enable\_dns64](#input\_enable\_dns64) | Enables dns64 if IPv6 is being used | `bool` | `true` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | n/a | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | n/a | `bool` | `true` | no |
| <a name="input_env"></a> [env](#input\_env) | n/a | `string` | `"development"` | no |
| <a name="input_instance_tenancy"></a> [instance\_tenancy](#input\_instance\_tenancy) | n/a | `string` | `"default"` | no |
| <a name="input_ipv4"></a> [ipv4](#input\_ipv4) | n/a | <pre>object({<br>    bits                                        = number<br>    cidr_block                                  = string<br>    destination_cidr_block                      = string<br>    enable_resource_name_dns_a_record_on_launch = bool<br>  })</pre> | `null` | no |
| <a name="input_ipv6"></a> [ipv6](#input\_ipv6) | Configs for supporting IPv6 in the VPC | <pre>object({<br>    bits                                           = number<br>    assign_ipv6_address_on_creation                = bool<br>    destination_cidr_block                         = string<br>    enabled                                        = bool<br>    enable_dns64                                   = bool<br>    enable_resource_name_dns_aaaa_record_on_launch = bool<br>  })</pre> | `null` | no |
| <a name="input_private_dns_hostname_type_on_launch"></a> [private\_dns\_hostname\_type\_on\_launch](#input\_private\_dns\_hostname\_type\_on\_launch) | n/a | `string` | `"ip-name"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region the VPC is being created in | `any` | n/a | yes |
| <a name="input_region_code"></a> [region\_code](#input\_region\_code) | AWS abbreviation for the region the VPC is being created in | `any` | n/a | yes |
| <a name="input_subnet_tags"></a> [subnet\_tags](#input\_subnet\_tags) | Additional tags to apply to each subnet | `map` | <pre>{<br>  "private": {<br>    "cpco.io/subnet/type": "private"<br>  },<br>  "public": {<br>    "cpco.io/subnet/type": "public"<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | n/a |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | n/a |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | n/a |
<!-- END_TF_DOCS -->

## Testing

Run terraform plan to resources that module would create in examples/complete

```shell
make init upgrade=true
```

```shell
make plan
```

Run an init and plan to make sure there are no errors (Used by CircleCI):

```shell
make test
```
