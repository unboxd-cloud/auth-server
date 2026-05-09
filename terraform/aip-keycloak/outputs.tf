output "realm_names" {
  description = "Keycloak realms managed for AIP."
  value       = { for environment, realm in keycloak_realm.aip : environment => realm.realm }
}

output "platform_agent_clients" {
  description = "Platform agent Keycloak client IDs by environment and agent key."
  value = {
    for key, client in keycloak_openid_client.platform_agent : key => {
      realm     = keycloak_realm.aip[local.realm_agent_matrix[key].environment].realm
      client_id = client.client_id
      agent_id  = local.realm_agent_matrix[key].agent.agent_id
      scopes    = local.realm_agent_matrix[key].agent.scopes
    }
  }
}

output "platform_agent_vault_paths" {
  description = "Expected secret destinations for bootstrap code that stores generated Keycloak client secrets."
  value = {
    for key, item in local.realm_agent_matrix : key => "secret/aip/${item.environment}/platform-agents/${item.agent.agent_id}/client-secret"
  }
}
