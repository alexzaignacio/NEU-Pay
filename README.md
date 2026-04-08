# NEU-Pay

> Campus Payment Platform — Flutter (Web + Mobile) · Spring Boot · MySQL · OAuth2/OIDC · Docker

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Security Design](#security-design)
- [Docker & CI/CD](#docker--cicd)
- [Flutter Frontend](#flutter-frontend)
- [Spring Boot Backend](#spring-boot-backend)
- [Environment Variables](#environment-variables)
- [Contributing](#contributing)

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────┐
│                     Client Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │  Flutter Web  │  │  Flutter iOS │  │Flutter Android│   │
│  │  (Nginx SPA)  │  │  (iPhone 8+) │  │              │   │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘   │
│         │                 │                  │           │
│         └────────────┬────┴──────────────────┘           │
│                      │ HTTPS + Bearer JWT                │
├──────────────────────┼───────────────────────────────────┤
│              ┌───────▼────────┐                          │
│              │  Spring Boot   │ ◄── OAuth2 Resource      │
│              │  REST API      │     Server (JWT)         │
│              └───────┬────────┘                          │
│                      │ JPA                               │
│              ┌───────▼────────┐                          │
│              │     MySQL      │                          │
│              │   (Database)   │                          │
│              └────────────────┘                          │
├──────────────────────────────────────────────────────────┤
│  Identity Provider: Keycloak / Auth0 (OIDC)              │
└──────────────────────────────────────────────────────────┘
```

## Tech Stack

| Layer         | Technology                          | Purpose                                    |
| ------------- | ----------------------------------- | ------------------------------------------ |
| **Frontend**  | Flutter 3.x (Dart)                  | Cross-platform UI (Web, iOS, Android)      |
| State Mgmt    | Riverpod                            | Reactive, testable state management        |
| Routing       | GoRouter                            | Declarative URL-based navigation           |
| **Backend**   | Spring Boot 3.4 (Java 21)          | REST API server                            |
| Persistence   | Spring Data JPA + MySQL 8.4        | Relational data storage                    |
| Security      | Spring Security + OAuth2 RS (JWT)   | Stateless authentication & authorization   |
| **Infra**     | Docker + Docker Compose             | Containerisation & local orchestration     |
| Web Server    | Nginx 1.27                          | Serve Flutter Web + reverse proxy          |
| Identity      | Keycloak 26 (or Auth0)             | OIDC provider for SSO                      |

## Project Structure

```
NEU-Pay/
├── backend/                         # Spring Boot application
│   ├── Dockerfile                   # Multi-stage build (Maven → JRE)
│   ├── pom.xml                      # Maven dependencies
│   └── src/
│       ├── main/
│       │   ├── java/com/neupay/backend/
│       │   │   ├── NeuPayApplication.java
│       │   │   ├── config/          # Security, CORS configuration
│       │   │   ├── controller/      # REST controllers
│       │   │   ├── dto/             # Data Transfer Objects
│       │   │   ├── exception/       # Global error handling
│       │   │   ├── model/           # JPA entities
│       │   │   ├── repository/      # Spring Data repositories
│       │   │   └── service/         # Business logic
│       │   └── resources/
│       │       ├── application.yml
│       │       ├── application-dev.yml
│       │       └── application-test.yml
│       └── test/
├── frontend/                        # Flutter application
│   ├── Dockerfile                   # Multi-stage build (Flutter → Nginx)
│   ├── nginx.conf                   # Production Nginx config
│   ├── pubspec.yaml
│   ├── web/                         # Web entry point
│   │   └── index.html
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart                 # Root MaterialApp.router
│   │   ├── core/
│   │   │   ├── constants/           # API URLs, breakpoints
│   │   │   ├── network/             # Dio HTTP client + auth interceptor
│   │   │   ├── router/              # GoRouter configuration
│   │   │   └── theme/               # Light / Dark Material 3 themes
│   │   ├── features/
│   │   │   ├── auth/                # Login screen + OIDC auth provider
│   │   │   └── home/                # Home dashboard
│   │   └── shared/
│   │       └── widgets/             # ResponsiveScaffold (adaptive layout)
│   └── test/
├── docker-compose.yml               # Full-stack local orchestration
├── .env.example                     # Environment variable template
├── .gitignore
└── README.md
```

## Prerequisites

| Tool            | Version  | Purpose                         |
| --------------- | -------- | ------------------------------- |
| Docker Desktop  | 24+      | Container runtime               |
| Docker Compose  | v2+      | Service orchestration           |
| Flutter SDK     | 3.5+     | Local mobile development        |
| Java JDK        | 21       | Backend local development       |
| Maven           | 3.9+     | Backend build (or use `./mvnw`) |

## Getting Started

### 1. Clone & configure

```bash
git clone https://github.com/alexzaignacio/NEU-Pay.git
cd NEU-Pay
cp .env.example .env          # Edit values as needed
```

### 2. Start all services via Docker

```bash
docker compose up -d --build
```

This spins up:

| Service      | URL                                   |
| ------------ | ------------------------------------- |
| Frontend     | http://localhost                       |
| Backend API  | http://localhost:8080/api              |
| Keycloak     | http://localhost:8180                  |
| MySQL        | localhost:3306                         |

### 3. Configure Keycloak (first time)

1. Open http://localhost:8180 → Admin Console → login with `admin / admin`
2. Create realm: **neupay**
3. Create client: **neupay-flutter** (Public client, redirect URI: `com.neupay.app://callback` and `http://localhost/*`)
4. Create user(s) for testing

### 4. Local Flutter development (mobile)

```bash
cd frontend
flutter pub get
flutter run                   # Launches on connected device / emulator
```

To run as web locally (outside Docker):

```bash
flutter run -d chrome --web-renderer html
```

### 5. Local backend development

```bash
cd backend
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

---

## Security Design

### Authentication Flow (OAuth2 / OIDC)

```
┌──────────┐    1. Login redirect     ┌──────────────┐
│  Flutter  │ ───────────────────────► │   Keycloak   │
│  Client   │ ◄─────────────────────── │   (OIDC)     │
│           │    2. Auth code + tokens │              │
└─────┬─────┘                          └──────────────┘
      │ 3. API call with Bearer JWT
      ▼
┌──────────────┐    4. Validate JWT     ┌──────────────┐
│  Spring Boot │ ──────────────────────►│  Keycloak    │
│  Resource    │    (JWKS endpoint)     │  PublicKey    │
│  Server      │                        └──────────────┘
└──────────────┘
```

### Security measures implemented

| Layer        | Measure                                                     |
| ------------ | ----------------------------------------------------------- |
| Transport    | HTTPS enforced in production (TLS termination at LB/Nginx) |
| Auth         | OAuth2 Authorization Code + PKCE (via `flutter_appauth`)    |
| API          | Stateless JWT validation (no server-side sessions)          |
| CORS         | Explicit origin allowlist, credentials enabled              |
| Headers      | `X-Frame-Options`, `X-Content-Type-Options`, CSP headers    |
| Data         | JPA parameterised queries (prevents SQL injection)          |
| Input        | Bean Validation (`@Valid`) on all incoming DTOs              |
| Secrets      | No secrets in images; injected via environment variables     |
| Containers   | Non-root users in all Docker images                         |
| Storage      | Mobile tokens stored in `flutter_secure_storage` (Keychain/Keystore) |
| Error Handling | Global exception handler – no stack traces leaked to client |

---

## Docker & CI/CD

### Individual Dockerfiles

**Backend** (`backend/Dockerfile`):
- Multi-stage: Maven build → JRE-only Alpine runtime image
- Spring Boot layered JAR for optimal Docker layer caching
- Runs as non-root `neupay` user
- Health check via Actuator `/api/actuator/health`

**Frontend** (`frontend/Dockerfile`):
- Multi-stage: Flutter SDK build → Nginx Alpine runtime
- HTML web renderer for fast load on low-end devices
- Gzip compression, aggressive caching for static assets
- SPA fallback routing + API reverse proxy to backend

### CI/CD Integration

The Dockerfiles are CI/CD-ready. Example GitHub Actions workflow:

```yaml
# .github/workflows/build.yml
name: Build & Push

on:
  push:
    branches: [main]

jobs:
  backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/build-push-action@v6
        with:
          context: ./backend
          push: true
          tags: ghcr.io/alexzaignacio/neupay-backend:latest

  frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/build-push-action@v6
        with:
          context: ./frontend
          push: true
          tags: ghcr.io/alexzaignacio/neupay-frontend:latest
```

---

## Flutter Frontend

### Responsive Design Strategy

The app uses a `ResponsiveScaffold` that adapts across three breakpoints:

| Breakpoint   | Width      | Navigation         | Optimised for            |
| ------------ | ---------- | ------------------ | ------------------------ |
| **Mobile**   | < 600dp    | Bottom nav bar     | iPhone 8 (375pt) and up  |
| **Tablet**   | 600–1200dp | Navigation rail    | iPad, small laptops      |
| **Desktop**  | ≥ 1200dp   | Fixed side drawer  | Full desktop browsers    |

### Web Performance

- **HTML renderer** (`--web-renderer html`) avoids downloading the 2MB+ CanvasKit WASM binary, ensuring fast initial load on low-spec machines
- Nginx serves pre-compressed assets with `gzip` and `Cache-Control: immutable` headers
- PWA manifest enables "Add to Home Screen" support

### State Management

Riverpod provides compile-time safety and testability. Providers are organised by feature:

```
features/
  auth/
    providers/auth_provider.dart    # OIDC login/logout state
  home/
    providers/                      # Dashboard state
```

---

## Spring Boot Backend

### API Endpoints

| Method | Path                 | Auth     | Description               |
| ------ | -------------------- | -------- | ------------------------- |
| GET    | `/api/v1/me`         | Required | Get current user profile  |
| POST   | `/api/v1/me/provision` | Required | Auto-provision user from JWT |
| GET    | `/api/v1/health`     | Required | Service health check      |
| GET    | `/api/actuator/health` | Public | Docker/K8s health probe   |

### Profiles

| Profile | Purpose                              | DDL Mode        |
| ------- | ------------------------------------ | --------------- |
| *default* | Production-ready                   | `validate`      |
| `dev`   | Local development, verbose logging   | `update`        |
| `test`  | Unit tests with H2 in-memory DB      | `create-drop`   |

---

## Environment Variables

| Variable               | Default                                    | Description                     |
| ---------------------- | ------------------------------------------ | ------------------------------- |
| `DB_HOST`              | `localhost`                                | MySQL hostname                  |
| `DB_PORT`              | `3306`                                     | MySQL port                      |
| `DB_NAME`              | `neupay`                                   | Database name                   |
| `DB_USERNAME`          | `neupay`                                   | Database user                   |
| `DB_PASSWORD`          | `neupay`                                   | Database password               |
| `OAUTH2_ISSUER_URI`    | `http://localhost:8180/realms/neupay`      | OIDC issuer                     |
| `SERVER_PORT`          | `8080`                                     | Backend port                    |
| `MYSQL_ROOT_PASSWORD`  | `rootpassword`                             | MySQL root (Docker only)        |
| `KEYCLOAK_ADMIN_PASSWORD` | `admin`                                 | Keycloak admin (Docker only)    |

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit with conventional commits: `git commit -m "feat: add payment endpoint"`
4. Push and open a Pull Request
5. Ensure Docker builds pass: `docker compose build`

---

**License:** TBD