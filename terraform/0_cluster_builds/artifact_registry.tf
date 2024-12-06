module "docker-artifact-registry" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/artifact-registry?ref=v35.0.0"

  project_id = module.project.project_id
  location   = var.primary_region
  name       = format("af-%s-docker", var.primary_region)
  format = {
    docker = {
      standard = {}
    }
  }
}

module "argocd-fleet-sync-artifact-registry" {
  source = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/artifact-registry?ref=v35.0.0"

  project_id = module.project.project_id
  location   = var.primary_region
  name       = "argocd-fleet-sync"
  format = {
    docker = {
      standard = {}
    }
  }
}