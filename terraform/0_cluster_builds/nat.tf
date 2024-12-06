module "nat" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-cloudnat?ref=v35.0.0"

  for_each = { for subnet in distinct([for subnet in module.vpc.subnets : subnet.region]): subnet => subnet}

  project_id     = module.project.project_id
  region         = each.value
  name           = each.value
  router_network = module.vpc.self_link
}