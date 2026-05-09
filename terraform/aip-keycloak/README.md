# AIP Keycloak Terraform

[TERRAFORM] This module bootstraps the first AIP identity backbone primitives in Keycloak v24+:

- one realm per environment: `aip-dev`, `aip-staging`, and `aip-prod`;
- one confidential OpenID Connect client per named platform agent;
- service accounts enabled for client-credentials-only agent identity;
- client scopes mapped to each platform agent's allowlist;
- initial AIP JWT claim mappers for `agent_id`, `agent_type`, `tenant_id`, `del_chain`, and `act`.

The generated Keycloak client secret is intentionally not stored in Terraform variables, source code, or environment files. A bootstrap job must read the generated credential from Keycloak and write it to the emitted `platform_agent_vault_paths` destination in Vault or AWS Secrets Manager.

## Usage

```bash
terraform init
terraform plan \
  -var='keycloak_url=https://keycloak.example.com' \
  -var='keycloak_client_id=terraform-admin'
```

Provider authentication must come from the operator's secure Terraform runtime (for example, injected CI secrets or a short-lived admin token). Do not commit provider credentials or tfstate files.

## Notes

The hardcoded claim mappers are a bootstrapping bridge. They satisfy the token shape for the six platform service accounts before the custom Keycloak SPI mapper exists. The SPI mapper will replace these defaults for dynamic token-exchange fields such as delegated `del_chain` and `act`.

[SELFEVAL]
- [ ] Keycloak token introspects successfully for this agent? Requires live Keycloak apply and client secret retrieval.
- [ ] Scope attenuation enforced — no escalation possible? Client scopes are allowlisted here; token-exchange attenuation will be enforced in the AIP middleware/OPA follow-up.
- [ ] Audit log entry written before action completes? Not in scope for Terraform client bootstrap.
- [ ] De-provisioning propagates in <500ms? Not in scope for Terraform client bootstrap.
- [x] No secrets in code — all in Vault? Terraform emits Vault paths only and does not commit credentials.
- [ ] OPA policy covers this new resource/action pair? OPA policies come in the PEP/PDP feature.
- [ ] TypeScript compiles with zero errors in strict mode? No TypeScript changed in this Terraform-only increment.
