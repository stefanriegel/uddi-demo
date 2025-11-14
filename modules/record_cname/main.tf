resource "bloxone_dns_cname_record" "this" {
  zone = var.zone_fqdn
  name = var.record_name
  ttl  = var.ttl

  # If your provider version expects top-level attribute 'canonical', replace the rdata block accordingly.
  rdata = {
    canonical = var.cname_target
  }
}
