locals {
  # Build the rdata object based on the record type.
  rdata = var.record_type == "A"    ? { address  = var.record_value } :
          var.record_type == "AAAA" ? { address6 = var.record_value } :
                                      { text     = var.record_value }
}

resource "bloxone_dns_record" "this" {
  zone = var.zone_fqdn
  name = var.record_name
  type = var.record_type
  ttl  = var.ttl

  rdata = local.rdata
}
