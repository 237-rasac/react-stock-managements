# SGS — Système de Gestion de Stock

SGS is a multi-company inventory-management platform for managing catalogues, stock, customers, suppliers, orders, counter sales, users, notifications, and business KPIs.

This repository contains two applications:

- **`backend/`** — Spring Boot REST API backed by PostgreSQL.
- **`SGS-app/`** — React single-page application consuming the API.

The system is designed around stock traceability: stock changes are recorded as movements, multi-line operations are transactional, and each company can access only its own business data.

## Main capabilities

- Multi-company / multi-tenant data isolation.
- JWT authentication with access-token and refresh-token rotation.
- Role-based access control:
  - `SUPER_ADMIN` — platform administration and company onboarding.
  - `ADMIN` — administration of a client company and its users.
  - `GESTIONNAIRE` — catalogue, suppliers, orders, stock, and reporting operations.
  - `VENDEUR` — counter sales and relevant catalogue/customer access.
- Category and article management.
- Customer and supplier management.
- Customer orders with validation, shipping, delivery, and cancellation workflows.
- Supplier orders with full and partial reception workflows.
- Counter sales with immediate stock deduction.
- Stock state, low-stock alerts, valuation, and movement history.
- Dashboard KPIs and stock charts.
- Best-effort email notifications for customer and supplier orders.
- French and English frontend translations.
- Swagger/OpenAPI documentation.

## Technology stack

### Frontend

- React 19
- TypeScript 7
- Vite 8
- Tailwind CSS 4
- React Router 8
- Axios
- TanStack Query and TanStack Table
- Zustand
- React Hook Form and Zod
- i18next / react-i18next
- Recharts, Lucide React, and Sonner
- Vitest, Testing Library, and Playwright
- Oxlint and Prettier

### Backend

- Java 17
- Spring Boot 3.4.1
- Spring Web and Spring Data JPA
- PostgreSQL
- Flyway database migrations
- Spring Security
- JWT via jjwt 0.12.6
- Spring Validation
- Spring Mail
- springdoc-openapi / Swagger UI
- Maven Wrapper
- Lombok

## Repository structure

```text
.
├── backend/
│   ├── src/main/java/com/sgs/backend/
│   │   ├── config/              # Security, JWT, CORS, bootstrap, OpenAPI
│   │   ├── auth/                # Refresh-token persistence and services
│   │   ├── dashboard/           # KPI and chart endpoints
│   │   ├── article/             # Article catalogue
│   │   ├── categorie/           # Categories
│   │   ├── client/              # Customers
│   │   ├── fournisseur/         # Suppliers
│   │   ├── commandeClient/      # Customer orders
│   │   ├── commandeFournisseur/ # Supplier orders
│   │   ├── vente/               # Counter sales
│   │   ├── mvtStk/              # Stock movements
│   │   ├── stock/               # Derived stock views
│   │   ├── notification/        # Low-stock notifications and email
│   │   ├── entreprise/           # Companies
│   │   └── utilisateur/          # Users
│   └── src/main/resources/
│       ├── application.yaml
│       ├── application-prod.yaml
│       └── db/migration/         # Flyway migrations
│
└── SGS-app/
    ├── src/
    │   ├── app/                 # Providers and central router
    │   ├── api/                 # Axios client, tokens, interceptors
    │   ├── components/          # Shared UI, layouts, forms, tables
    │   ├── features/            # Feature-based business modules
    │   ├── i18n/                # Global translation setup
    │   ├── lib/                 # Constants, permissions, formatters
    │   ├── routes/              # Protected and role-aware routes
    │   ├── stores/              # Client-side Zustand state
    │   └── styles/              # Global styles and design tokens
    ├── e2e/                     # Playwright smoke tests
    ├── package.json
    └── swagger.json             # Frontend/API contract reference
```

## Architecture and data flow

```text
Browser
  │
  │ React pages and feature hooks
  ▼
TanStack Query / Zustand
  │
  ▼
Feature API modules
  │
  ▼
Central Axios client
  │  Bearer JWT + refresh-token recovery
  ▼
Spring Boot REST API
  │  Security, tenant isolation, business rules
  ▼
Service and repository layers
  │
  ▼
PostgreSQL
```

The frontend follows a feature-based structure. Each feature generally owns its API functions, DTO/domain mappers, types, schemas, hooks, pages, components, and translations. TanStack Query owns server data; Zustand is reserved for client/application state such as authentication UI, theme, and sidebar state.

The backend follows domain-oriented packages with controllers, services, repositories, entities, DTOs, and business exceptions. Flyway migrations in `backend/src/main/resources/db/migration` are the source of truth for the database schema.

## Requirements

Install the following before starting development:

- Java 17+
- Node.js compatible with the versions in `SGS-app/package.json`
- npm
- PostgreSQL 13+ recommended
- A PostgreSQL database, for example `stock_db`

## Quick start

### 1. Create the database

Create a PostgreSQL database and user, or use an existing local PostgreSQL installation:

```sql
CREATE DATABASE stock_db;
```

The backend defaults to:

```text
DB_URL=jdbc:postgresql://localhost:5432/stock_db
DB_USERNAME=postgres
DB_PASSWORD
```

For any non-local environment, provide explicit values through environment variables instead of relying on these development defaults.

### 2. Start the backend

From the repository root:

```bash
cd backend
./mvnw spring-boot:run
```

On Windows, use:

```bat
cd backend
mvnw.cmd spring-boot:run
```

The API starts on **http://localhost:8081**. Flyway applies the migrations automatically at startup.

### 3. Configure and start the frontend

In a second terminal:

```bash
cd SGS-app
npm install
cp .env.example .env
npm run dev
```

On Windows, copy `.env.example` to `.env` using your shell or file manager. The default frontend configuration is:

```dotenv
VITE_API_URL=/api
VITE_APP_NAME=SGS
```

Vite serves the application at **http://localhost:5173** and proxies `/api` to the backend at `http://localhost:8081`. Using the proxy avoids local cross-origin issues.

Open **http://localhost:5173** in a browser.

## Development configuration

### Backend environment variables

| Variable | Default / requirement | Purpose |
|---|---|---|
| `DB_URL` | `jdbc:postgresql://localhost:5432/stock_db` | PostgreSQL JDBC URL |
| `DB_USERNAME` | `postgres` | Database user |
| `DB_PASSWORD` | `` | Database password |
| `JWT_SECRET` | Development fallback only | Secret used to sign JWTs |
| `JWT_EXPIRATION` | `` | Access-token lifetime in milliseconds; 24 hours by default |
| `JWT_REFRESH_DAYS` | `7` | Refresh-token lifetime in days |
| `MAIL_USERNAME` | Empty by default | SMTP username |
| `MAIL_PASSWORD` | Empty by default | SMTP password |

The production profile requires `JWT_SECRET` and does not provide a fallback. Generate a strong value, for example with `openssl rand -base64 64`, and start with:

```bash
cd backend
./mvnw spring-boot:run -Dspring-boot.run.profiles=prod
```

### Frontend environment variables

| Variable | Example | Purpose |
|---|---|---|
| `VITE_API_URL` | `/api` | API base URL; `/api` uses the Vite development proxy |
| `VITE_APP_NAME` | `SGS` | Application metadata |

Do not put secrets in frontend environment variables. Vite exposes `VITE_*` values to the browser.

## Authentication and first login

On a fresh development database, the backend bootstrap initializer creates:

- Platform account: `admin@sgs.local`
- Password: `admin123`
- Demo company: `SGS Demo`

Use these credentials only for local development. Change or remove them before deploying the application. The bootstrap credentials are defined by the backend initializer and are not a production secret-management mechanism.

Authentication uses:

1. `POST /api/auth/login` to obtain an access token and refresh token.
2. `Authorization: Bearer <access-token>` for protected requests.
3. `POST /api/auth/refresh` to rotate the token pair after access-token expiry.
4. `POST /api/auth/logout` to revoke the refresh token.

The frontend stores tokens locally and automatically retries requests after a valid refresh. The backend is stateless and does not use server-side sessions.

## Core business workflows

### Customer order

```text
Create order (EN_COURS)
  → validate (VALIDEE; stock OUT movements created)
  → ship (EXPEDIEE)
  → deliver (LIVREE)
```

An order can be cancelled while it is `EN_COURS`. Validation is transactional: if any line lacks sufficient stock, the entire operation is rejected.

### Supplier order

```text
Create order (EN_ATTENTE)
  → receive fully (RECUE; stock IN movements created)
  → or receive partially (RECUE_PARTIELLEMENT)
```

Pending supplier orders can be cancelled. Reception cannot create stock above the ordered quantities.

### Counter sale

```text
Create sale
  → validate stock availability
  → create immediate stock OUT movements
```

Sales are immutable historical records: they cannot be updated or deleted.

### Stock traceability

Stock changes use the following movement types:

- `ENTREE` — stock increase, normally from supplier reception.
- `SORTIE` — stock decrease, normally from customer-order validation or sales.
- `AJUSTEMENT` — signed manual correction, which requires a reason.

Stock cannot become negative. Stock state and valuation are derived from articles and movements rather than maintained as an unrelated data source.

## API documentation and main resources

With the backend running, open:

- Swagger UI: **http://localhost:8081/swagger-ui.html**
- OpenAPI JSON: **http://localhost:8081/api-docs**
- OpenAPI v3 JSON: **http://localhost:8081/v3/api-docs**

The main API resource groups are:

| Resource | Base path | Purpose |
|---|---|---|
| Authentication | `/api/auth` | Login, registration, profile, refresh, logout |
| Companies | `/api/entreprises` | Company management |
| Users | `/api/utilisateurs` | Company user management |
| Categories | `/api/categories` | Article categorization |
| Articles | `/api/articles` | Catalogue CRUD |
| Customers | `/api/clients` | Customer records |
| Suppliers | `/api/fournisseurs` | Supplier records |
| Customer orders | `/api/commandes-client` | Customer order lifecycle |
| Supplier orders | `/api/commandes-fournisseur` | Purchasing and reception |
| Sales | `/api/ventes` | Counter sales |
| Stock | `/api/stock` | State, alerts, and valuation |
| Stock movements | `/api/mouvements-stock` | History and manual adjustments |
| Notifications | `/api/notifications` | Computed low-stock alerts |
| Dashboard | `/api/dashboard` | KPIs and chart data |
| Platform | `/api/plateforme` | Platform statistics and onboarding |

All resources except the explicitly public authentication and documentation endpoints require a valid JWT and are subject to role and company isolation rules.

## Frontend routes

Routes are language-prefixed (`/fr/...` or `/en/...`) and protected where necessary. Main areas include:

- `/:lang/login`
- `/:lang/dashboard`
- `/:lang/platform`
- `/:lang/platform/companies`
- `/:lang/catalog/categories`
- `/:lang/catalog/articles`
- `/:lang/customers`
- `/:lang/suppliers`
- `/:lang/customer-orders`
- `/:lang/supplier-orders`
- `/:lang/sales`
- `/:lang/stock`
- `/:lang/stock/movements`
- `/:lang/stock/alerts`
- `/:lang/notifications`
- `/:lang/profile`
- `/:lang/settings`

The router enforces authentication, tenant access, and role-aware navigation. Backend authorization remains the actual security boundary.

## Commands

### Frontend (`SGS-app`)

```bash
npm run dev             # Start Vite development server
npm run build           # Typecheck and build production assets
npm run preview         # Preview the production build
npm run typecheck       # TypeScript check without emitting files
npm run lint            # Run oxlint
npm test                # Run Vitest unit/component tests
npm run test:live       # Run optional live API audit
npm run audit:endpoints # Compare frontend endpoint usage with swagger.json
npm run audit:i18n      # Check French/English translation parity
```

Playwright smoke tests can be run with the project’s configured Playwright command:

```bash
npx playwright test
```

The E2E suite uses mocked `/api` responses and does not require the backend for its basic smoke coverage.

### Backend (`backend`)

```bash
./mvnw spring-boot:run    # Start the API
./mvnw test               # Run backend tests
./mvnw clean verify       # Clean, test, and verify the project
./mvnw package            # Build the application artifact
```

On Windows, replace `./mvnw` with `mvnw.cmd`.

## Testing and quality checks

A typical local verification sequence is:

```bash
cd SGS-app
npm run typecheck
npm run lint
npm test
npm run build

cd ../backend
./mvnw test
```

The frontend also has CI and pre-commit quality checks configured in the project. Keep feature tests close to their implementation using `*.test.ts` or `*.test.tsx` naming.

## Production notes

Before deploying:

- Set a unique, strong `JWT_SECRET`; the `prod` profile requires it.
- Set production PostgreSQL credentials and `DB_URL`.
- Never use the development database password or bootstrap credentials.
- Review CORS allowed origins in `backend/src/main/java/com/sgs/backend/config/CorsConfig.java`.
- Configure SMTP only if email notifications are required.
- Build and serve the frontend from a trusted static hosting setup.
- Ensure frontend `VITE_API_URL` points to the deployed API or to a correctly configured reverse proxy.
- Run database migrations through Flyway and keep migration files versioned.
- Treat frontend role checks as UX only; rely on backend authorization for security.

## Further documentation

- [`SGS-app/README.md`](SGS-app/README.md) — detailed frontend implementation notes, conventions, and current UI scope.
- [`SGS-app/architecture.md`](SGS-app/architecture.md) — frontend architecture and responsibility boundaries.
- [`SGS-app/PRD.md`](SGS-app/PRD.md) — product requirements and business rules.
- [`SGS-app/swagger.json`](SGS-app/swagger.json) — frontend-side API contract reference.
- [`backend/src/main/resources/db/migration/`](backend/src/main/resources/db/migration/) — versioned database migrations.
