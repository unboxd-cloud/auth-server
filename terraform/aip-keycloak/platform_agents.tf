locals {
  # Six platform agents provisioned at platform boot. Keycloak service accounts are
  # the agent identities; client credentials are retrieved into Vault/Secrets Manager
  # by the platform bootstrap pipeline and are never committed to source control.
  platform_agents = {
    onboarding_agent = {
      client_id   = "aip-platform-onboarding"
      agent_id    = "onboarding_agent"
      description = "Customer enrollment state machine"
      scopes = [
        "tenant:create",
        "tenant:read",
        "tenant:update",
        "scim:write",
        "ciba:initiate",
        "sso:configure",
        "billing:enroll",
        "healthcheck:run",
        "ssf:emit",
        "audit:write",
      ]
    }

    registry_agent = {
      client_id   = "aip-platform-registry"
      agent_id    = "registry_agent"
      description = "Agent discovery, trust evaluation, ACP HELLO gate, and health checks"
      scopes = [
        "registry:read",
        "registry:write",
        "registry:expire",
        "ciba:initiate",
        "agent:trust_evaluate",
        "healthcheck:run",
        "audit:write",
        "ssf:emit",
      ]
    }

    lifecycle_agent = {
      client_id   = "aip-platform-lifecycle"
      agent_id    = "lifecycle_agent"
      description = "Provision, rotate, suspend, and deprovision tenant agents"
      scopes = [
        "agent:create",
        "agent:suspend",
        "agent:deprovision",
        "agent:rotate_credentials",
        "scim:write",
        "token:revoke",
        "acl:purge",
        "ssf:emit",
        "audit:write",
        "ciba:initiate",
      ]
    }

    audit_agent = {
      client_id   = "aip-platform-audit"
      agent_id    = "audit_agent"
      description = "Append-only audit log steward and Keycloak event ingest owner"
      scopes = [
        "audit:read",
        "audit:write",
        "audit:ingest:keycloak",
      ]
    }

    super_admin_agent = {
      client_id   = "aip-platform-superadmin"
      agent_id    = "super_admin_agent"
      description = "Break-glass administration; every action is human-CIBA-gated"
      scopes = [
        "policy:write",
        "ciba:initiate",
        "tenant:read",
        "tenant:update",
        "agent:suspend",
        "agent:deprovision",
        "token:revoke",
        "acl:purge",
        "audit:write",
      ]
    }

    ssf_relay_agent = {
      client_id   = "aip-platform-ssf"
      agent_id    = "ssf_relay_agent"
      description = "Shared Signals Framework CAEP/RISC SET broadcast and delivery receipts"
      scopes = [
        "ssf:emit",
        "ssf:read",
        "ssf:receipt:write",
        "audit:write",
      ]
    }
  }

  platform_agent_scopes = toset(flatten([
    for agent in local.platform_agents : agent.scopes
  ]))

  realm_agent_matrix = {
    for pair in setproduct(var.environments, keys(local.platform_agents)) :
    "${pair[0]}:${pair[1]}" => {
      environment = pair[0]
      agent_key   = pair[1]
      agent       = local.platform_agents[pair[1]]
    }
  }

  realm_scope_matrix = {
    for pair in setproduct(var.environments, local.platform_agent_scopes) :
    "${pair[0]}:${pair[1]}" => {
      environment = pair[0]
      scope       = pair[1]
    }
  }
}

resource "keycloak_realm" "aip" {
  for_each = var.environments

  realm             = "aip-${each.key}"
  enabled           = true
  display_name      = "AIP ${title(each.key)}"
  display_name_html = "AIP ${title(each.key)}"

  access_token_lifespan = "5m"
  ssl_required          = each.key == "dev" ? "external" : "all"
}

resource "keycloak_openid_client_scope" "platform_agent" {
  for_each = local.realm_scope_matrix

  realm_id               = keycloak_realm.aip[each.value.environment].id
  name                   = each.value.scope
  description            = "AIP platform-agent permission: ${each.value.scope}"
  include_in_token_scope = true
}

resource "keycloak_openid_client" "platform_agent" {
  for_each = local.realm_agent_matrix

  realm_id  = keycloak_realm.aip[each.value.environment].id
  client_id = each.value.agent.client_id
  name      = each.value.agent.agent_id

  description = each.value.agent.description
  enabled     = true

  access_type                              = var.client_access_type
  service_accounts_enabled                 = true
  standard_flow_enabled                     = false
  implicit_flow_enabled                     = false
  direct_access_grants_enabled              = false
  oauth2_device_authorization_grant_enabled = false

  valid_redirect_uris = []
  web_origins         = []

  extra_config = {
    "aip.agent_id"                              = each.value.agent.agent_id
    "aip.agent_type"                            = "platform"
    "aip.tenant_id"                             = "platform"
    "aip.credential_vault_path"                 = "secret/aip/${each.value.environment}/platform-agents/${each.value.agent.agent_id}/client-secret"
    "oauth2.device.authorization.grant.enabled" = "false"
    "backchannel.logout.session.required"       = "false"
  }
}

resource "keycloak_openid_client_default_scopes" "platform_agent" {
  for_each = local.realm_agent_matrix

  realm_id  = keycloak_realm.aip[each.value.environment].id
  client_id = keycloak_openid_client.platform_agent[each.key].id

  default_scopes = concat(
    ["acr", "profile", "roles", "web-origins"],
    each.value.agent.scopes,
  )

  depends_on = [keycloak_openid_client_scope.platform_agent]
}

# Initial mappers provide the AIP-required JWT shape for service-account tokens.
# The production custom Keycloak SPI mapper will replace these hardcoded defaults
# once it can derive del_chain/act dynamically during token exchange.
resource "keycloak_openid_hardcoded_claim_protocol_mapper" "agent_id" {
  for_each = local.realm_agent_matrix

  realm_id  = keycloak_realm.aip[each.value.environment].id
  client_id = keycloak_openid_client.platform_agent[each.key].id
  name      = "aip-agent-id"

  claim_name       = "agent_id"
  claim_value      = each.value.agent.agent_id
  claim_value_type = "String"

  add_to_access_token = true
  add_to_id_token     = false
  add_to_userinfo     = false
}

resource "keycloak_openid_hardcoded_claim_protocol_mapper" "agent_type" {
  for_each = local.realm_agent_matrix

  realm_id  = keycloak_realm.aip[each.value.environment].id
  client_id = keycloak_openid_client.platform_agent[each.key].id
  name      = "aip-agent-type"

  claim_name       = "agent_type"
  claim_value      = "platform"
  claim_value_type = "String"

  add_to_access_token = true
  add_to_id_token     = false
  add_to_userinfo     = false
}

resource "keycloak_openid_hardcoded_claim_protocol_mapper" "tenant_id" {
  for_each = local.realm_agent_matrix

  realm_id  = keycloak_realm.aip[each.value.environment].id
  client_id = keycloak_openid_client.platform_agent[each.key].id
  name      = "aip-tenant-id"

  claim_name       = "tenant_id"
  claim_value      = "platform"
  claim_value_type = "String"

  add_to_access_token = true
  add_to_id_token     = false
  add_to_userinfo     = false
}

resource "keycloak_openid_hardcoded_claim_protocol_mapper" "del_chain" {
  for_each = local.realm_agent_matrix

  realm_id  = keycloak_realm.aip[each.value.environment].id
  client_id = keycloak_openid_client.platform_agent[each.key].id
  name      = "aip-delegation-chain"

  claim_name       = "del_chain"
  claim_value      = "[]"
  claim_value_type = "JSON"

  add_to_access_token = true
  add_to_id_token     = false
  add_to_userinfo     = false
}

resource "keycloak_openid_hardcoded_claim_protocol_mapper" "act" {
  for_each = local.realm_agent_matrix

  realm_id  = keycloak_realm.aip[each.value.environment].id
  client_id = keycloak_openid_client.platform_agent[each.key].id
  name      = "aip-actor"

  claim_name       = "act"
  claim_value      = "null"
  claim_value_type = "JSON"

  add_to_access_token = true
  add_to_id_token     = false
  add_to_userinfo     = false
}
