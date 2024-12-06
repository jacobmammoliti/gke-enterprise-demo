module "gke-clusters-autopilot" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/gke-cluster-autopilot?ref=v35.0.0"

  for_each = { for cluster in local.gke_clusters : format("%s-%s", cluster.region, cluster.type) => cluster if cluster.type == "application" }

  project_id = module.project.project_id
  name       = format("%s-%s-%s", lookup(local.cluster_types, each.value.type), lookup(local.cluster_tiers, each.value.tier), lookup(local.cluster_regions, each.value.region))
  location   = each.value.region

  vpc_config = {
    network    = module.vpc.name
    subnetwork = module.vpc.subnets[format("%s/sb-%s-%s-%s", each.value.region, each.value.tier, module.vpc.name, each.value.region)].name

    secondary_range_names = {
      pods     = "pods"
      services = "services"
    }
  }

  private_cluster_config = {
    enable_private_endpoint = false
    master_global_access    = false
  }

  enable_addons = {
    config_connector = false
  }

  # enable_features = {
  #   workload_identity = true
  #   dataplane_v2      = true
  # }

  deletion_protection = false
}

module "gke-clusters-standard" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/gke-cluster-standard?ref=v35.0.0"

  for_each = { for cluster in local.gke_clusters : format("%s-%s", cluster.region, cluster.type) => cluster if cluster.type == "control" }

  project_id = module.project.project_id
  name       = format("%s-%s-%s", lookup(local.cluster_types, each.value.type), lookup(local.cluster_tiers, each.value.tier), lookup(local.cluster_regions, each.value.region))
  location   = each.value.region

  vpc_config = {
    network    = module.vpc.name
    subnetwork = module.vpc.subnets[format("%s/sb-%s-%s-%s", each.value.region, each.value.tier, module.vpc.name, each.value.region)].name

    secondary_range_names = {
      pods     = "pods"
      services = "services"
    }

    # master_authorized_ranges = {
    #   internal-vms = "10.0.0.0/8"
    # }

    master_ipv4_cidr_block = "10.200.0.0/24"
  }

  # private_cluster_config = {
  #   enable_private_endpoint = false
  #   master_global_access    = false
  #   enable_private_nodes    = true
  # }

  enable_addons = {
    config_connector           = false
    horizontal_pod_autoscaling = true
  }

  enable_features = {
    workload_identity = true
  }

  deletion_protection = false
}

module "gke-nodepools-standard" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/gke-nodepool?ref=v35.0.0"

  for_each = { for cluster in local.gke_clusters : format("%s-%s", cluster.region, cluster.type) => cluster if cluster.type == "control" }

  project_id   = module.project.project_id
  name         = format("%s-%s-%s-nodepool-1", lookup(local.cluster_types, each.value.type), lookup(local.cluster_tiers, each.value.tier), lookup(local.cluster_regions, each.value.region))
  location     = each.value.region
  cluster_name = module.gke-clusters-standard[each.key].name

  node_config = {
    machine_type        = "n2-standard-2" # vCPUs: 2, RAM: 8GiB
    disk_size_gb        = 50
    disk_type           = "pd-ssd"
    ephemeral_ssd_count = 1
    spot                = true
  }

  node_count = {
    initial = 1
  }

  nodepool_config = {
    autoscaling = {
      max_node_count  = 3
      location_policy = "ANY"
      min_node_count  = 1
    }
  }
}

module "hub" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/gke-hub?ref=v35.0.0"
  project_id = module.project.project_id

  clusters = {
    for cluster in module.gke-clusters-autopilot : cluster.name => cluster.id
  }

  features = {
    appdevexperience             = false
    configmanagement             = false
    identityservice              = false
    servicemesh                  = false
    multiclusterservicediscovery = false
  }

  # configmanagement_clusters = {
  #   "default" = [for cluster in merge(module.gke_clusters_standard, module.gke_clusters_autopilot) : cluster.name]
  # }

  # configmanagement_templates = {
  #   default = {
  #     config_sync = {
  #       git = {
  #         policy_dir    = "configsync"
  #         source_format = "unstructured"
  #         sync_branch   = "main"
  #         sync_repo     = "https://github.com/jacobmammoliti/gke-demo"
  #       }
  #       source_format = "unstructured"
  #     }
  #     policy_controller = {
  #       audit_interval_seconds     = 120
  #       log_denies_enabled         = true
  #       referential_rules_enabled  = true
  #       template_library_installed = true
  #     }
  #     version = "1.19.2"
  #   }
  # }

  workload_identity_clusters = [for cluster in module.gke-clusters-autopilot : cluster.name]

  # depends_on = [module.gke-nodepools-standard]
}