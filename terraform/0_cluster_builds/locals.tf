locals {
  gke_clusters = yamldecode(file("${path.module}/data.yaml"))["clusters"]
  vpc          = yamldecode(file("${path.module}/data.yaml"))["vpc"]

  cluster_tiers = {
    "non-production" = "np",
    "production"     = "p",
  }

  cluster_regions = {
    "northamerica-northeast2" = "nane2",
    "us-west4"                = "uw4",
  }

  cluster_types = {
    "control"     = "c",
    "application" = "a",
  }
}