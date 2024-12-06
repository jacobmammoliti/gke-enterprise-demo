module "vpc" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-vpc?ref=v35.0.0"

  project_id = module.project.project_id
  name       = local.vpc.name

  subnets = flatten([
    for environment, subnet in local.vpc.subnets : [
      for region in subnet : {
        region              = region.region
        ip_cidr_range       = region.ip_cidr
        name                = format("sb-%s-%s-%s", environment, local.vpc.name, region.region)
        secondary_ip_ranges = { for name, cidr in region.secondary_ranges : name => cidr }
      }
    ]
  ])

  psa_configs = try(flatten([
    for environment, subnet in local.vpc.subnets : [
      for region in subnet : [
        for range in region.psa_ranges : {
          ranges = {
            format("%s-%s", environment, region.region) = range.range
          }
        }
      ]
    ]
  ]), null)
}