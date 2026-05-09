# Client Configuration Guide

Guide to configuring OAuth/OIDC clients in Auth Server.

## Create a Client

### Via Admin Console

1. Go to **Clients** → **Create**
2. Enter **Client ID**
3. Set **Client Protocol** to `openid-connect`

### Client Settings

| Setting | Description | Default |
|---------|-------------|---------|
| Client ID | Unique identifier | Required |
| Name | Display name | - |
| Description | Client description | - |
| Enabled | Enable/disable client | true |
| Always Display in Consent | Show consent screen | false |
| Consent Screen Terms | Terms текст | - |
| Front Channel Logout | Front-channel logout | false |
| Bearer Only | Service accounts only | false |
| Standard Flow | Authorization Code flow | true |
| Direct Access Grants | Password/client credentials | false |
| Implicit Flow | Implicit flow | false |
| Root URL | Application root URL | - |
| Valid Redirect URIs | Allowed callback URLs | - |
| Web Origins | CORS allowed origins | - |

## Client Types

### Confidential Client

For server-side applications that can securely store secrets.

```json
{
  "clientId": "my-server-app",
  "publicClient": false,
  "standardFlowEnabled": true,
  "directAccessGrantsEnabled": false,
  "secret": "generated-secret"
}
```

### Public Client

For SPA and mobile apps.

```json
{
  "clientId": "my-spa-app",
  "publicClient": true,
  "standardFlowEnabled": true,
  "directAccessGrantsEnabled": false,
  "redirectUris": ["https://myapp.com/callback"]
}
```

### Service Account

For machine-to-machine authentication.

```json
{
  "clientId": "my-service",
  "publicClient": false,
  "standardFlowEnabled": false,
  "directAccessGrantsEnabled": true,
  "serviceAccountsEnabled": true,
  "secret": "service-secret"
}
```

## Authentication Settings

### Authentication Flow Override

```json
{
  "authenticationFlowBindingOverrides": {
    "browser": "browser-flow-id",
    "direct-grant": "direct-grant-flow-id"
  }
}
```

### OAuth 2.0 Browser Security

```json
{
  "standardFlowEnabled": true,
  "implicitFlowEnabled": false,
  "directAccessGrantsEnabled": false,
  "publicClient": true
}
```

## Advanced Settings

### Token Settings

```json
{
  "accessTokenLifespan": 300,
  "accessTokenLifespanRememberMe": 600,
  "accessTokenLifespanForImplicitFlow": 300,
  "saslAllowedProtocols": ["openid-connect"]
}
```

###Consent Settings

```json
{
  "consentRequired": true,
  "displayOnConsentScreen": true,
  "consentScreenText": "Allow my-app to access your profile"
}
```

## ClientScopes

### Default ClientScopes

- `openid`
- `profile`
- `email`
- `phone`
- `address`
- `offline_access`

### Creating ClientScope

1. Go to **Client Scopes** → **Create**
2. Enter name and protocol
3. Add **Protocol Mapper** if needed

### Protocol Mappers

Custom claims in tokens:

```json
{
  "name": "my-custom-claim",
  "protocol": "openid-connect",
  "protocolMapper": "oidc-usermodel-attribute-mapper",
  "config": {
    "claim.name": "custom_claim",
    "user.attribute": "myAttribute",
    "jsonType.label": "String"
  }
}
```

## Client Installation

### Download Installation JSON

Go to **Clients** → **Installation** → **Format Option**

```json
{
  "realm": "my-app",
  "auth-server-url": "https://authserver.unboxd.cloud",
  "ssl-required": "external",
  "resource": "my-app",
  "credentials": {
    "secret": "client-secret"
  }
}
```