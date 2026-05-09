# Security Guide

Security best practices for Auth Server.

## Authentication Security

### Enable Multi-Factor Authentication (MFA)

1. Go to **Authentication** → **Browser** → **Actions** → **Config**
2. Enable **OTP** or **WebAuthn**
3. Make required for all users

### Password Policies

1. Go to **Authentication** → **Password Policy**
2. Configure minimum requirements:
   - Length: 12+ characters
   - Special characters required
   - Numbers required
   - Uppercase required
   - Not username
   - Not common password

### Brute Force Protection

1. Go to **Realm Settings** → **Security Defenses**
2. Configure:
   - **Brute Force Detection**: Enabled
   - **Max Login Failures**: 5
   - **Wait Increase**: 30 seconds
   - **Failure Reset Time**: 24 hours

## Token Security

### Access Token Settings

```json
{
  "accessTokenLifespan": 300,
  "accessTokenLifespanForImplicitFlow": 300,
  "revokeRefreshToken": true,
  "refreshTokenMaxReuse": 0
}
```

### Refresh Token Rotation

Each refresh token can be used once only. Configure:

```json
{
  "refreshTokenMaxReuse": 0,
  "reuseRefreshToken": false
}
```

### Enable Code Verification (PKCE)

Always use PKCE for Authorization Code flow:

```
?code_challenge=ChallengeHash
&code_challenge_method=S256
```

## Transport Security

### HTTPS Only

Force HTTPS for all connections:

```bash
kc.sh start --https-key-alias=key --https-key-password=password
```

### Certificate Configuration

Configure trusted certificates:

```bash
kc.sh start \
  --truststore=truststore.p12 \
  --truststore-password=password
```

### CORS Settings

Restrict allowed origins:

```json
{
  "webOrigins": ["https://myapp.com", "https://app.mycompany.com"]
}
```

## Authorization Security

### Role-Based Access Control (RBAC)

1. Go to **Users** → **Role Mappings**
2. Assign realm roles:
   - `offline_access`
   - `uma_authorization`
   - `default-roles-{realm-name}`

### Client Scopes

Limit token claims:

```json
{
  "clientScopes": ["openid", "profile", "email", "address"]
}
```

## Security Headers

Configure reverse proxy to add headers:

```nginx
add_header X-Frame-Options "SAMEORIGIN";
add_header X-Content-Type-Options "nosniff";
add_header X-XSS-Protection "1; mode=block";
add_header Referrer-Policy "no-referrer";
add_header Content-Security-Policy "default-src 'self'";
```

## Audit Logging

Enable security events:

1. Go to **Realm Settings** → **Events**
2. Enable **Login events settings**
3. Configure **Event listeners**: `jboss-logging`
4. Save admin events to external log

## Best Practices Checklist

- [ ] Use HTTPS in production
- [ ] Enable MFA for admin users
- [ ] Set strong password policy (12+ chars)
- [ ] Enable brute force protection
- [ ] Use PKCE for all clients
- [ ] Rotate refresh tokens
- [ ] Set short access token lifespan (5 min)
- [ ] Restrict redirect URIs
- [ ] Restrict web origins
- [ ] Enable audit logging
- [ ] Review login events regularly
- [ ] Use secure cookies (httponly, secure)
- [ ] Implement rate limiting