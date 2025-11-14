# Registers/links the zone in UDDI and associates Cloudflare as an external provider.
# Note: external_providers schema may vary slightly by provider version. Adjust if your version differs.
resource "bloxone_dns_auth_zone" "this" {
  fqdn = var.zone_fqdn

  # Link the external provider (Cloudflare) by account context.
  external_providers {
    provider_type = "cloudflare"
    account_id    = var.cloudflare_account_id
  }

  # Optional: add comments/tags to make the demo easier to spot in UDDI
  comment = "UDDI + Cloudflare Demo zone managed by Terraform"
}
