# How to Use Auth Server

A quick start guide for using Auth Server at `https://authserver.unboxd.cloud`.

## Quick Start

### 1. Access Admin Console

Go to: **https://authserver.unboxd.cloud/admin/**

Login with your admin credentials.

### 2. Create a Realm

1. Click the realm dropdown (top-left)
2. Click **Add Realm**
3. Enter a name: `my-application`
4. Click **Create**

### 3. Create a Client

1. Go to **Clients** → **Create client**
2. Settings:
   - **Client ID**: `web-app`
   - **Client Protocol**: `openid-connect`
   - **Root URL**: `http://localhost:3000`
3. In **Valid Redirect URIs**, add:
   - `http://localhost:3000/callback`
   - `http://localhost:3000/*`
4. Click **Save**

### 4. Create a User

1. Go to **Users** → **Add user**
2. Enter:
   - **Username**: `demo`
   - **Email**: `demo@example.com`
   - **First Name**: `Demo`
   - **Last Name**: `User`
3. Click **Save**
4. Go to **Credentials** tab
5. Set password: `demo123`
6. Turn off **Temporary** toggle
7. Click **Set Password**

### 5. Test Authentication

Open your browser and navigate to:

```
https://authserver.unboxd.cloud/realms/my-application/protocol/openid-connect/auth
  ?response_type=code
  &client_id=web-app
  &redirect_uri=http://localhost:3000/callback
  &scope=openid%20profile%20email
  &state=random123
```

Login with:
- Username: `demo`
- Password: `demo123`

## Integration Examples

### JavaScript (Frontend)

```html
<!DOCTYPE html>
<html>
<head>
  <title>My App</title>
</head>
<body>
  <button id="login">Login with Auth Server</button>
  <div id="user"></div>
  
  <script>
    const authUrl = 'https://authserver.unboxd.cloud/realms/my-application/protocol/openid-connect/auth';
    const clientId = 'web-app';
    const redirectUri = 'http://localhost:3000/callback';
    
    document.getElementById('login').onclick = () => {
      const state = Math.random().toString(36);
      sessionStorage.setItem('oauth_state', state);
      
      const url = authUrl +
        '?response_type=code' +
        '&client_id=' + clientId +
        '&redirect_uri=' + encodeURIComponent(redirectUri) +
        '&scope=openid%20profile%20email' +
        '&state=' + state;
      
      window.location.href = url;
    };
  </script>
</body>
</html>
```

### Node.js (Express)

```javascript
const express = require('express');
const axios = require('axios');

const app = express();

const config = {
  realm: 'my-application',
  authUrl: 'https://authserver.unboxd.cloud/realms/my-application/protocol/openid-connect',
  clientId: 'web-app',
  clientSecret: 'your-client-secret',
  redirectUri: 'http://localhost:3000/callback'
};

app.get('/login', (req, res) => {
  const state = Math.random().toString(36);
  const url = config.authUrl + '/auth' +
    '?response_type=code' +
    '&client_id=' + config.clientId +
    '&redirect_uri=' + config.redirectUri +
    '&scope=openid%20profile%20email' +
    '&state=' + state;
  
  req.session.oauthState = state;
  res.redirect(url);
});

app.get('/callback', async (req, res) => {
  try {
    const { code, state } = req.query;
    
    if (state !== req.session.oauthState) {
      return res.status(400).send('Invalid state');
    }
    
    const tokenResponse = await axios.post(
      config.authUrl + '/token',
      new URLSearchParams({
        grant_type: 'authorization_code',
        code: code,
        redirect_uri: config.redirectUri,
        client_id: config.clientId,
        client_secret: config.clientSecret
      })
    );
    
    const { access_token, id_token } = tokenResponse.data;
    
    // Get user info
    const userInfo = await axios.get(
      config.authUrl + '/userinfo',
      { headers: { Authorization: 'Bearer ' + access_token } }
    );
    
    res.json(userInfo.data);
  } catch (err) {
    res.status(500).send(err.message);
  }
});

app.listen(3000);
```

### Python (Flask)

```python
from flask import Flask, redirect, session, request, jsonify
import requests

app = Flask(__name__)
app.secret_key = 'secret'

CONFIG = {
    'realm': 'my-application',
    'auth_url': 'https://authserver.unboxd.cloud/realms/my-application/protocol/openid-connect',
    'client_id': 'web-app',
    'client_secret': 'your-client-secret',
    'redirect_uri': 'http://localhost:3000/callback'
}

@app.route('/login')
def login():
    import secrets
    state = secrets.token_hex(16)
    session['oauth_state'] = state
    
    url = f"{CONFIG['auth_url']}/auth" + \
        f"?response_type=code" + \
        f"&client_id={CONFIG['client_id']}" + \
        f"&redirect_uri={CONFIG['redirect_uri']}" + \
        f"&scope=openid%20profile%20email" + \
        f"&state={state}"
    
    return redirect(url)

@app.route('/callback')
def callback():
    code = request.args.get('code')
    state = request.args.get('state')
    
    if state != session.get('oauth_state'):
        return 'Invalid state', 400
    
    # Exchange code for token
    token_response = requests.post(
        f"{CONFIG['auth_url']}/token",
        data={
            'grant_type': 'authorization_code',
            'code': code,
            'redirect_uri': CONFIG['redirect_uri'],
            'client_id': CONFIG['client_id'],
            'client_secret': CONFIG['client_secret']
        }
    ).json()
    
    access_token = token_response['access_token']
    
    # Get user info
    user_info = requests.get(
        f"{CONFIG['auth_url']}/userinfo",
        headers={'Authorization': f'Bearer {access_token}'}
    ).json()
    
    return jsonify(user_info)

if __name__ == '__main__':
    app.run(port=3000)
```

### Go

```go
package main

import (
    "encoding/json"
    "fmt"
    "math/rand"
    "net/http"
    "net/url"
    "time"
    
    "github.com/coreos/go-oidc/v3/authorization"
)

func main() {
    http.HandleFunc("/login", loginHandler)
    http.HandleFunc("/callback", callbackHandler)
    http.ListenAndServe(":3000", nil)
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
    chars := []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    state := make([]rune, 16)
    for i := range state {
        state[i] = chars[rand.Intn(len(chars))]
    }
    
    config := authorization.Config{
        ClientID:    "web-app",
        Scope:     []string{"openid", "profile", "email"},
        RedirectURL: "http://localhost:3000/callback",
    }
    
    authURL, _ := url.Parse("https://authserver.unboxd.cloud/realms/my-application/protoid-connect/auth")
    q := authURL.Query()
    q.Set("response_type", "code")
    q.Set("client_id", config.ClientID)
    q.Set("redirect_uri", config.RedirectURL)
    q.Set("scope", "openid profile email")
    q.Set("state", string(state))
    authURL.RawQuery = q.Encode()
    
    http.Redirect(w, r, authURL.String(), http.StatusFound)
}

func callbackHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintln(w, "Callback received!")
}
```

## Next Steps

- [ ] Configure production database
- [ ] Enable HTTPS
- [ ] Set up user federation (LDAP/AD)
- [ ] Configure MFA
- [ ] Set up role mapping
- [ ] Enable audit logging
- [ ] Review security settings