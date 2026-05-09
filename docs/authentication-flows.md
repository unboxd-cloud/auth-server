# Authentication Flows

Complete guide to authentication flows supported by Auth Server.

## Authorization Code Flow

The recommended flow for web applications. Uses PKCE (Proof Key for Code Exchange) for enhanced security.

### Step 1: Authorization Request

Redirect the user to the authorization endpoint:

```
https://authserver.unboxd.cloud/realms/{realm}/protocol/openid-connect/auth
  ?response_type=code
  &client_id={client_id}
  &redirect_uri={redirect_uri}
  &scope=openid%20profile%20email
  &state={random_state}
  &code_challenge={pkce_challenge}
  &code_challenge_method=S256
```

Generate PKCE code challenge:

```javascript
// Node.js example
const crypto = require('crypto');
const base64url = (buf) => buf.toString('base64')
  .replace(/\+/g, '-')
  .replace(/\//g, '_')
  .replace(/=/g, '');

const verifier = base64url(crypto.randomBytes(32));
const challenge = base64url(
  crypto.createHash('sha256').update(verifier).digest()
);
```

### Step 2: User Authentication

The user logs in at the Auth Server login page.

### Step 3: Authorization Code

After successful login, redirect to your callback URL with the authorization code:

```
https://myapp.com/callback
  ?code={authorization_code}
  &state={random_state}
```

### Step 4: Token Exchange

Exchange the code for tokens:

```bash
curl -X POST https://authserver.unboxd.cloud/realms/{realm}/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=authorization_code" \
  -d "code={authorization_code}" \
  -d "redirect_uri={redirect_uri}" \
  -d "client_id={client_id}" \
  -d "client_secret={client_secret}" \
  -d "code_verifier={pkce_verifier}"
```

### Step 5: Use the Access Token

```bash
curl -H "Authorization: Bearer {access_token}" \
  https://api.myapp.com/userinfo
```

## Implicit Flow (Deprecated)

**⚠️ Not recommended.** Use Authorization Code + PKCE instead.

### Flow

```
https://authserver.unboxd.cloud/realms/{realm}/protocol/openid-connect/auth
  ?response_type=token
  &client_id={client_id}
  &redirect_uri={redirect_uri}
  &scope=openid%20profile
  &state={random_state}
```

Returns tokens directly in the redirect fragment.

## Resource Owner Password Credentials Flow

For trusted clients only (e.g., first-party mobile apps).

### Request

```bash
curl -X POST https://authserver.unboxd.cloud/realms/{realm}/protocol/openid-connect/token \
  -d "grant_type=password" \
  -d "username={username}" \
  -d "password={password}" \
  -d "client_id={client_id}" \
  -d "client_secret={client_secret}"
```

### Response

```json
{
  "access_token": "...",
  "expires_in": 300,
  "refresh_token": "...",
  "id_token": "...",
  "token_type": "Bearer"
}
```

## Client Credentials Flow

For machine-to-machine authentication (no user context).

### Request

```bash
curl -X POST https://authserver.unboxd.cloud/realms/{realm}/protocol/openid-connect/token \
  -d "grant_type=client_credentials" \
  -d "client_id={client_id}" \
  -d "client_secret={client_secret}"
```

### Response

```json
{
  "access_token": "eyJ...",
  "expires_in": 300,
  "token_type": "Bearer"
}
```

## Refresh Token Flow

Refresh an expired access token:

```bash
curl -X POST https://authserver.unboxd.cloud/realms/{realm}/protocol/openid-connect/token \
  -d "grant_type=refresh_token" \
  -d "refresh_token={refresh_token}" \
  -d "client_id={client_id}" \
  -d "client_secret={client_secret}"
```

## Device Flow

For device apps (smart TVs, CLI tools).

### Step 1: Device Authorization

```bash
curl -X POST https://authserver.unboxd.cloud/realms/{realm}/protocol/openid-connect/device/auth \
  -d "client_id={client_id}"
```

### Response

```json
{
  "device_code": "...",
  "user_code": "ABCD-1234",
  "verification_uri": "https://authserver.unboxd.cloud/device",
  "verification_uri_complete": "https://authserver.unboxd.cloud/device?user_code=ABCD-1234",
  "expires_in": 1800,
  "interval": 5
}
```

### Step 2: User Authorizes

### Step 3: Poll for Token

```bash
curl -X POST https://authserver.unboxd.cloud/realms/{realm}/protocol/openid-connect/token \
  -d "grant_type=urn:ietf:params:oauth:grant-type:device_code" \
  -d "device_code={device_code}" \
  -d "client_id={client_id}"
```

## SAML Artifact Flow

For SAML-based integrations.

See the [SAML Integration Guide](./saml.html) for details.