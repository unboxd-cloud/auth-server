# Unboxd AuthServer Documentation

Welcome to the Unboxd AuthServer documentation. This server is deployed at `https://authserver.unboxd.cloud`.

## Overview

Unboxd AuthServer is an enterprise-grade authentication and authorization platform built on Keycloak. It provides:

- OAuth 2.0 and OpenID Connect (OIDC) support
- JWT token management
- User federation and identity management
- Role-based access control (RBAC)

## Server Information

| Property | Value |
|----------|-------|
| **URL** | https://authserver.unboxd.cloud |
| **Realm** | master (default) |
| **Protocol** | OpenID Connect |

## Getting Started

### 1. Access the Admin Console

Navigate to the admin console to manage realms, users, and clients:

```
https://authserver.unboxd.cloud/admin/
```

Log in with your admin credentials to create and manage realms.

### 2. Create a Realm

1. From the admin console, hover over the realm selector (top-left)
2. Click "Add Realm"
3. Enter a realm name (e.g., `my-app`)
4. Click "Create"

### 3. Create a Client

Clients represent applications that authenticate through Auth Server.

1. Select your realm
2. Go to **Clients** → **Create client**
3. Configure:
   - **Client ID**: `my-application`
   - **Client Protocol**: `openid-connect`
   - **Root URL**: `https://myapp.com`
   - **Valid Redirect URIs**: `https://myapp.com/callback`
   - **Web Origins**: `https://myapp.com`

### 4. Create Users

1. Go to **Users** → **Add user**
2. Fill in user details
3. Set a password in the **Credentials** tab

## Integration

### Node.js (Express)

```javascript
const Keycloak = require('keycloak-connect');
const express = require('express');

const app = express();
const keycloak = new Keycloak({
  'realm': 'my-app',
  'auth-server-url': 'https://authserver.unboxd.cloud',
  'client-id': 'my-application',
  'client-secret': 'YOUR_CLIENT_SECRET'
});

app.use(keycloak.middleware());

app.get('/api', keycloak.protect(), (req, res) => {
  res.json({ message: 'Protected route', user: req.kcauth });
});
```

### Java (Spring Boot)

```java
@Configuration
public class SecurityConfig extends WebSecurityConfigurerAdapter {
  @Override
  protected void configure(HttpSecurity http) throws Exception {
    http
      .authorizeRequests()
        .anyRequest().authenticated()
        .and()
      .oauth2Login()
        .authorizationEndpoint()
          .baseUri("/oauth/authorize")
        .and()
      .oauth2ResourceServer()
        .jwt();
  }
}
```

### Python (Flask)

```python
from flask import Flask
from flask_keycloak import Keycloak

app = Flask(__name__)
keycloak = Keycloak(app,
    keycloak_url='https://authserver.unboxd.cloud',
    realm='my-app',
    client_id='my-application'
)

@app.route('/api')
@keycloak.protect()
def api():
    return {'message': 'Protected'}
```

## Token Configuration

### JWT Settings

| Setting | Value |
|---------|-------|
| **Algorithm** | RS256 |
| **Token Lifespan** | 5 minutes |
| **Refresh Token Lifespan** | 30 minutes |
| **Offline Session Lifespan** | 30 days |

### OAuth 2.0 Flows Supported

- Authorization Code Flow (recommended for web apps)
- Implicit Flow (deprecated, not recommended)
- Resource Owner Password Credentials Flow (trusted clients only)
- Client Credentials Flow (machine-to-machine)

## Security Best Practices

1. **Use HTTPS** - Always use secure connections
2. **Rotate Secrets** - Change client secrets periodically
3. **Use Short Token Lifespans** - Reduce the window of opportunity for attacks
4. **Enable MFA** - Multi-factor authentication for admin users
5. **Audit Logs** - Monitor authentication events

## API Reference

### OpenID Connect Endpoints

| Endpoint | URL |
|----------|-----|
| Authorization | `https://authserver.unboxd.cloud/realms/{realm}/protocol/openid-connect/auth` |
| Token | `https://authserver.unboxd.cloud/realms/{realm}/protocol/openid-connect/token` |
| UserInfo | `https://authserver.unboxd.cloud/realms/{realm}/protocol/openid-connect/userinfo` |
| Logout | `https://authserver.unboxd.cloud/realms/{realm}/protocol/openid-connect/logout` |
| JWKS | `https://authserver.unboxd.cloud/realms/{realm}/protocol/openid-connect/certs` |

## Support

For issues or questions:
- Documentation: https://authserver.unboxd.cloud/docs
- Community: Join our Discord server
- Email: support@unboxd.cloud