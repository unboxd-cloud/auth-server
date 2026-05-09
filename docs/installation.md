# Installation Guide

This guide covers installing and starting the Auth Server using Keycloak.

## Prerequisites

- Java 17 or higher (JDK)
- 512MB RAM minimum (1GB recommended)
- 5GB free disk space

## Installation Methods

### Using ZIP Distribution

1. Download the Keycloak distribution:

```bash
wget https://github.com/keycloak/keycloak/releases/download/26.0.0/keycloak-26.0.0.zip
```

2. Extract the archive:

```bash
unzip keycloak-26.0.0.zip
cd keycloak-26.0.0
```

3. Start the server:

```bash
./bin/kc.sh start-dev
```

4. Access the admin console:

```
http://localhost:8080/admin/
```

### Using Docker

```bash
docker run -p 8080:8080 \
  -e KC_BOOTSTRAP_ADMIN_USERNAME=admin \
  -e KC_BOOTSTRAP_ADMIN_PASSWORD=admin \
  quay.io/keycloak/keycloak:26.0.0 start-dev
```

### Using Docker Compose

```yaml
version: '3.8'

services:
  keycloak:
    image: quay.io/keycloak/keycloak:26.0.0
    ports:
      - "8080:8080"
    environment:
      - KC_BOOTSTRAP_ADMIN_USERNAME=admin
      - KC_BOOTSTRAP_ADMIN_PASSWORD=admin
    command: start-dev
```

## Configuration

### Database Configuration

PostgreSQL:

```bash
./bin/kc.sh start \
  --db=postgres \
  --db-url=jdbc:postgresql://localhost:5432/keycloak \
  --db-username=keycloak \
  --db-password=password
```

MySQL:

```bash
./bin/kc.sh start \
  --db=mysql \
  --db-url=jdbc:mysql://localhost:3306/keycloak \
  --db-username=keycloak \
  --db-password=password
```

### HTTPS Configuration

Generate a keystore:

```bash
keytool -genkeypair \
  -alias keycloak \
  -keyalg RSA \
  -keysize 2048 \
  -validity 365 \
  -keystore keystore.p12 \
  -storepass password \
  -keypass password \
  -dname "CN=authserver.unboxd.cloud"
```

Start with HTTPS:

```bash
./bin/kc.sh start \
  --https-certificate-key-file=keystore.p12 \
  --https-certificate-key-store-password=password \
  --https-port=8443
```

## Operating Modes

### Development Mode

For local development:

```bash
./bin/kc.sh start-dev
```

- HTTP enabled
- Auto-generated dev URLs
- No database (H2 in-memory)

### Production Mode

```bash
./bin/kc.sh start \
  --db=postgres \
  --https-certificate-key-file=keystore.p12 \
  --hostname=authserver.unboxd.cloud
```

## Health Check

```bash
curl http://localhost:8080/health/ready
curl http://localhost:8080/health/live
```