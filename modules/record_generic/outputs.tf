locals {
  zone_nodot  = trimsuffix(var.zone_fqdn, ".")
  record_fqdn = var.record_name == "" ? "${local.zone_nodot}." : "${var.record_name}.${local.zone_nodot}."
}

output "record_id" {
  description = "UDDI record object ID"
  value       = bloxone_dns_record.this.id
}

output "record_fqdn" {
  description = "FQDN of the created record with trailing dot"
  value       = local.record_fqdn
}
