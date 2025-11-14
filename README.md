# UDDI + Cloudflare Demo (BloxOne Terraform)

Diese Demo zeigt, wie externe DNS in Cloudflare zentral via Infoblox UDDI verwaltet wird — automatisiert mit Terraform (Provider: `infobloxopen/bloxone`) und orchestriert per GitHub Actions als klickbare Web-UI.

## Architektur

```
+------------------+        +---------------------------+
| GitHub Actions   |        | Terraform (BloxOne Prov.)| 
| - workflow_dispatch (UI)  |---------------------------| 
| - plan/apply/destroy      |   provider "bloxone"      | 
| - dig verification         |   resources/modules       | 
+-----------+------+        +--------------+------------+ 
            |                                | 
            v                                v 
      +-----+------+               +---------+---------+ 
      |  Infoblox  |               |  Cloudflare DNS  | 
      |   UDDI     | <-- sync -->  |  (external DNS)  | 
      | Auth-Zone  |  external     |  Zone/Records    | 
      | + external_providers       +------------------+ 
      +------------+
```

## Ziel und Nutzen

- Einfache, reproduzierbare Demo, die in wenigen Minuten A/AAAA/TXT/CNAME Records in Cloudflare ausrollt — über UDDI und Terraform.
- Sichtbarer "One pane of glass": Änderungen erscheinen im UDDI Portal und im Cloudflare Dashboard.
- Klickbare Web-UI via GitHub Actions mit parametrierten Inputs — ideal für Demos/Presales.

## Voraussetzungen

- Terraform ≥ 1.4 (lokal optional, Actions liefert Terraform automatisch)
- GitHub Repository und Environment `dev` mit:
  - Vars:
    - `BLOXONE_HOST` (z. B. https://csp.infoblox.com)
    - `CF_ACCOUNT_ID` (Cloudflare Account ID)
  - Secrets:
    - `BLOXONE_API_KEY` (UDDI/BloxOne API Key)
- Die DNS-Zone existiert im angegebenen Cloudflare Account bzw. ist durch UDDI verwaltbar.
- Zone FQDN immer mit trailing dot: `virtualife.pro.`

## Quick Start (GitHub Actions)

1. Gehe zu Actions → "Run UDDI + Cloudflare Demo" → "Run workflow".
2. Setze Inputs:
   - `zone_fqdn` = `virtualife.pro.`
   - `record_name` = `www`
   - `record_type` = `A`
   - `record_value` = `203.0.113.10`
   - `ttl` = `120`
   - `action` = `apply`
3. Beobachte Plan/Apply. Die Zone wird (falls nötig) mit Cloudflare verknüpft (`external_providers`), der Record wird erstellt und UDDI synchronisiert zu Cloudflare.
4. Der Job lädt dig-Output als Artifact `demo-proof` hoch und zeigt eine Markdown-Zusammenfassung.

**Destroy:**
- Starte den Workflow erneut mit identischen Inputs und `action=destroy`.

## Demo-Szenarien

- **A-Record**: `www.virtualife.pro.` → `203.0.113.10`
- **CNAME Blue/Green**:
  - Apply mit `record_type=CNAME`, `record_name=app`, `record_value=blue.example.net.`, `ttl=60`
  - Danach `record_value=green.example.net.` und erneut `apply` → schneller Cutover
- **ACME/DCV via TXT**:
  - `record_type=TXT`, `record_name=_acme-challenge.api`, `record_value=token`, `ttl=60`

## Lokale Nutzung (optional)

```bash
cd live/dev
terraform init
terraform plan -var="bloxone_api_key=$BLOXONE_API_KEY" \
  -var="cloudflare_account_id=$CF_ACCOUNT_ID" \
  -var="zone_fqdn=virtualife.pro." \
  -var="record_name=www" -var="record_type=A" -var="record_value=203.0.113.10" -var="ttl=120"
terraform apply -auto-approve ...
```

## Troubleshooting

- Stelle sicher, dass `zone_fqdn` und CNAME-Ziele mit Punkt enden.
- Niedrige TTLs (60–120s) reduzieren Cache-Effekte; Propagation kann dennoch Sekunden/Minuten dauern.
- Prüfe UDDI/Cloudflare Dashboards und die Workflow-Artefakte (`demo-proof`).
- Bei Destroy müssen dieselben Inputs verwendet werden, damit der lokale State-Cache gefunden wird.

## Sicherheit

- Keine Secrets in Dateien/Repo. API Key nur als GitHub Secret.
- Optional: Environment Gates (Required Reviewers) vor Apply.

## Projektstruktur

```
.
├── .gitignore
├── README.md
├── modules/
│   ├── cf_zone/              # Auth-Zone + external_providers=cloudflare
│   ├── record_generic/       # A/AAAA/TXT Records
│   └── record_cname/         # CNAME (Cutover)
├── live/
│   └── dev/
│       ├── main.tf            # Root-Composition
│       ├── variables.tf       # Variable declarations
│       ├── versions.tf        # Provider & versions
│       └── terraform.tfvars.example  # Example configuration
└── .github/workflows/
    └── run-demo.yml          # Klickbarer Demo-Workflow
```
