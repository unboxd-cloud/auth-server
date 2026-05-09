# API Reference

Complete API reference for the Auth Server endpoints.

## Base URL

```
https://authserver.unboxd.cloud
```

## OpenID Connect Endpoints

### Authorization Endpoint

```
GET /realms/{realm}/protocol/openid-connect/auth
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| response_type | string | Yes | `code` or `token` |
| client_id | string | Yes | Client identifier |
| redirect_uri | string | Yes | Callback URL |
| scope | string | Yes | Space-separated scopes (e.g., `openid profile email`) |
| state | string | No | CSRF protection token |
| nonce | string | No | JWT claim for replay protection |
| code_challenge | string | No | PKCE code challenge |
| code_challenge_method | string | No | `S256` or `plain` |

**Example:**

```
https://authserver.unboxd.cloud/realms/my-app/protocol/openid-connect/auth
  ?response_type=code
  &client_id=my-app
  &redirect_uri=https://myapp.com/callback
  &scope=openid+profile+email
  &state=xyz123
  &code_challenge=ChallengeHash
  &code_challenge_method=S256
```

### Token Endpoint

```
POST /realms/{realm}/protocol/openid-connect/token
```

**Content-Type:** `application/x-www-form-urlencoded`

**Request Body:**

| Parameter | Type | Description |
|-----------|------|-------------|
| grant_type | string | `authorization_code`, `refresh_token`, `client_credentials` |
| code | string | Authorization code (for `authorization_code`) |
| redirect_uri | string | Callback URL |
| client_id | string | Client ID |
| client_secret | string | Client secret |
| code_verifier | string | PKCE code verifier |
| refresh_token | string | Refresh token (for `refresh_token`) |

**Response:**

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 300,
  "refresh_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_expires_in": 1800,
  "token_type": "Bearer",
  "id_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "scope": "openid profile email"
}
```

### UserInfo Endpoint

```
GET /realms/{realm}/protocol/openid-connect/userinfo
```

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response:**

```json
{
  "sub": "user-id-123",
  "name": "John Doe",
  "given_name": "John",
  "family_name": "Doe",
  "email": "john@example.com",
  "email_verified": true,
  "preferred_username": "johnd"
}
```

### Logout Endpoint

```
POST /realms/{realm}/protocol/openid-connect/logout
```

**Request Body:**

| Parameter | Type | Description |
|-----------|------|-------------|
| refresh_token | string | Refresh token to invalidate |
| client_id | string | Client ID |

### Token Introspection

```
POST /realms/{realm}/protocol/openid-connect/token/introspect
```

**Request Body:**

| Parameter | Type | Description |
|-----------|------|-------------|
| token | string | Token to introspect |
| token_type_hint | string | `access_token` or `refresh_token` |

**Response:**

```json
{
  "active": true,
  "scope": "openid profile email",
  "client_id": "my-app",
  "username": "johnd",
  "exp": 1699565432,
  "iat": 1699565132,
  "sub": "user-id-123",
  "aud": ["my-app"],
  "iss": "https://authserver.unboxd.cloud/realms/my-app"
}
```

## JWKS Endpoint

```
GET /realms/{realm}/protocol/openid-connect/certs
```

**Response:**

```json
{
  "keys": [
    {
      "kid": "key-id-1",
      "kty": "RSA",
      "alg": "RS256",
      "use": "sig",
      "n": "0vx7agoebGcQcSuJGt8LFgUxfGaBiwbIK1...",
      "e": "AQAB"
    }
  ]
}
```

## Admin API Endpoints

### Users

#### List Users

```
GET /admin/realms/{realm}/users
```

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| first | int | First result offset |
| max | int | Maximum results |
| search | string | Search string |
| email | string | Email filter |
| username | string | Username filter |

#### Create User

```
POST /admin/realms/{realm}/users
```

**Request Body:**

```json
{
  "username": "johndoe",
  "enabled": true,
  "emailVerified": true,
  "email": "john@example.com",
  "firstName": "John",
  "lastName": "Doe"
}
```

#### Get User

```
GET /admin/realms/{realm}/users/{user-id}
```

#### Update User

```
PUT /admin/realms/{realm}/users/{user-id}
```

#### Delete User

```
DELETE /admin/realms/{realm}/users/{user-id}
```

#### Reset Password

```
PUT /admin/realms/{realm}/users/{user-id}/reset-password
```

**Request Body:**

```json
{
  "type": "password",
  "value": "newpassword123",
  "temporary": false
}
```

### Clients

#### List Clients

```
GET /admin/realms/{realm}/clients
```

#### Create Client

```
POST /admin/realms/{realm}/clients
```

**Request Body:**

```json
{
  "clientId": "my-app",
  "name": "My Application",
  "enabled": true,
  "publicClient": false,
  "protocol": "openid-connect",
  "rootUrl": "https://myapp.com",
  "redirectUris": ["https://myapp.com/callback"],
  "webOrigins": ["https://myapp.com"],
  "secret": "client-secret"
}
```

### Roles

#### List Realm Roles

```
GET /admin/realms/{realm}/roles
```

#### Create Realm Role

```
POST /admin/realms/{realm}/roles
```

**Request Body:**

```json
{
  "name": "admin",
  "description": "Administrator role"
}
```

## Error Codes

| Error Code | Description |
|----------|-------------|
| invalid_request | Invalid request parameters |
| unauthorized_client | Client not authorized |
| access_denied | Access denied |
| unsupported_response_type | Unsupported response type |
| invalid_scope | Invalid scope |
| server_error | Internal server error |
| temporarily_unavailable | Server temporarily unavailable |