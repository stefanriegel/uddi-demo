output "zone_id" {
  description = "BloxOne/UDDI Zone ID"
  value       = bloxone_dns_auth_zone.this.id
}

output "zone_fqdn" {
  description = "Zone FQDN with trailing dot"
  value       = bloxone_dns_auth_zone.this.fqdn
}
