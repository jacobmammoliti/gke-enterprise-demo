module "argocd-service-account" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/iam-service-account?ref=v35.0.0"
  project_id = module.project.project_id
  name       = "argocd-fleet-admin"

  iam = {
    "roles/iam.workloadIdentityUser" = [
      "serviceAccount:${module.project.project_id}.svc.id.goog[argocd/argocd-application-controller]",
      "serviceAccount:${module.project.project_id}.svc.id.goog[argocd/argocd-fleet-sync]",
    ]
  }
}

resource "google_project_iam_member" "argocd_iam" {
  for_each = { for role in ["roles/container.developer", "roles/gkehub.gatewayEditor", "roles/gkehub.viewer", "roles/container.admin"] : role => role }

  project = module.project.project_id
  role    = each.value
  member  = module.argocd-service-account.iam_email
}