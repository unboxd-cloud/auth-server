# Unboxd AuthServer

Authentication server deployed at **https://authserver.unboxd.cloud**

Built on Keycloak for enterprise-grade OAuth 2.0 and OpenID Connect authentication.

## Overview

Unboxd AuthServer is an enterprise-grade authentication and authorization platform providing:

- OAuth 2.0 and OpenID Connect (OIDC)
- JWT token management
- User federation and identity management
- Role-based access control (RBAC)

## Server Information

| Property | Value |
|----------|-------|
| **URL** | https://authserver.unboxd.cloud |
| **Admin** | https://authserver.unboxd.cloud/admin/ |
| **Protocol** | OpenID Connect |

## Quick Start

### 1. Access Admin Console

Navigate to: https://authserver.unboxd.cloud/admin/

### 2. Create a Realm

1. Click the realm dropdown → **Add Realm**
2. Enter a realm name (e.g., `my-app`)
3. Click **Create**

### 3. Create a Client

1. Go to **Clients** → **Create client**
2. Enter **Client ID** (e.g., `web-app`)
3. Set **Valid Redirect URIs** (e.g., `http://localhost:3000/callback`)
4. Click **Save**

### 4. Create a User

1. Go to **Users** → **Add user**
2. Enter user details
3. Set password in **Credentials** tab

## Features

- OAuth 2.0 & OIDC
- JWT Tokens
- MFA Support
- User Federation
- Client Scopes
- Role-Based Access Control
- Security Best Practices

## Documentation

- [Installation Guide](./docs/installation.md)
- [How to Use](./docs/how-to-use.md)
- [Authentication Flows](./docs/authentication-flows.md)
- [Client Configuration](./docs/client-configuration.md)
- [API Reference](./docs/api-reference.md)
- [Security Guide](./docs/security.md)

## Docker

```bash
docker-compose up --build
```

## License

MIT