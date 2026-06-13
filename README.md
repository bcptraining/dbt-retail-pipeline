# dbt Retail Pipeline

A production-style dbt project built on PostgreSQL, demonstrating a full analytics engineering workflow across isolated dev, QA, and production environments — all running locally via Docker.

---

## Project Overview

This project models a retail business domain (customers, products, orders, payments, inventory, stores, and web activity) through a layered dbt architecture:

- **Staging** — light transformations on raw seed data, materialized as views
- **Dimensions** — conformed dimension tables (customers, products, dates, stores)
- **Facts** — grain-level fact tables (orders, order items)

---

## Environment Architecture

Three isolated PostgreSQL servers run via Docker Compose, one per environment:

| Environment | Docker Container | Port  | Purpose                          |
|-------------|-----------------|-------|----------------------------------|
| `dev`       | `pg_dev`        | 5441  | Active development, personal sandbox |
| `qa`        | `pg_qa`         | 5442  | Integration testing, pre-release validation |
| `prod`      | `pg_prod`       | 5443  | Production data, clean schema names |

> **Note:** Ports 5441–5443 are used to avoid conflict with a local PostgreSQL 18 installation on port 5432.

Schema naming behavior (controlled by `macros/generate_schema_name.sql`):

- **dev** — schemas are prefixed with the developer's target schema (e.g., `coryp_staging`, `coryp_facts`) to prevent collisions if multiple developers share the server
- **qa / prod** — schemas use clean layer names only (`staging`, `dimensions`, `facts`, `raw`)

---

## Branch & Deployment Strategy

```
feature/xyz  ──►  develop  ──►  main
    │                │             │
   dev              qa           prod
```

| Branch      | Target Environment | Trigger                        |
|-------------|-------------------|--------------------------------|
| `feature/*` | dev               | Local dbt runs by the developer |
| `develop`   | qa                | GitHub Actions on push/PR merge |
| `main`      | prod              | GitHub Actions on PR merge from develop |

### Workflow

1. Create a `feature/` branch from `develop` for all new work
2. Run and test locally against the **dev** database
3. Open a PR into `develop` — GitHub Actions runs `dbt build` against **qa**
4. After QA passes, open a PR from `develop` into `main` — GitHub Actions runs `dbt build` against **prod**
5. Direct commits to `main` are not permitted

---

## Current Build Status

| Component | Status |
|-----------|--------|
| Project scaffold (seeds, staging, facts, dimensions) | ✅ Complete |
| Git repo with `main` / `develop` branch strategy | ✅ Complete |
| Docker Compose — 3 isolated PostgreSQL 15 servers | ✅ Complete |
| dbt profiles for dev / qa / prod | ✅ Complete |
| `dbt debug` passing on all 3 targets | ✅ Complete |
| GitHub Actions CI/CD workflows | 🔜 In progress |
| Remaining dimension models (dim_customers, dim_products, dim_stores) | 🔜 Pending |

---

## Local Setup

### Prerequisites

- Docker Desktop
- Python 3.9+
- dbt-postgres (`pip install dbt-postgres`)

### Start the databases

```bash
docker compose up -d
```

### Configure credentials

Copy the example profile and fill in passwords:

```bash
cp profiles.yml.example ~/.dbt/profiles.yml
```

> `profiles.yml` is excluded from version control. Never commit credentials.

### Run the pipeline

```bash
# dev environment (default)
dbt seed && dbt build

# qa environment
dbt seed --target qa && dbt build --target qa

# prod environment
dbt seed --target prod && dbt build --target prod
```

---

## Project Structure

```
dbt-retail-pipeline/
├── models/
│   ├── staging/       # Views on raw seed data
│   ├── dimensions/    # Dimension tables
│   └── facts/         # Fact tables
├── seeds/             # Source CSV data loaded into raw schema
├── macros/            # generate_schema_name, custom tests
├── .github/
│   └── workflows/     # CI/CD: dbt build on develop (qa) and main (prod)
├── docker-compose.yml # 3 PostgreSQL containers
├── profiles.yml.example
└── dbt_project.yml
```

---

## Custom Tests

| Test               | Description                                      |
|--------------------|--------------------------------------------------|
| `phone_format`     | Validates `999-999-9999` pattern                 |
| `valid_us_state`   | Checks two-letter US state/Canadian province     |
| `promo_code_format`| Validates promo code structure                   |

---

## Quick Build Script

`run_dbt_build.bat` is a Windows convenience script for running `dbt build` locally and capturing the output. Double-click it (or run it from a terminal) and it will:

- Run `dbt build` against the default dev target
- Redirect all output to a timestamped log file under `logs/`, e.g. `logs\dbt_build_FRI_20260612-0930.log`
- Print the log file path to the console when finished

The `logs/` folder is created automatically if it doesn't exist. Log files are excluded from version control.

---

## Good Idea Pile

- [About dbt Wizard CLI | dbt Developer Hub](https://docs.getdbt.com/docs/dbt-ai/about-dbt-wizard-cli?version=2.0&name=Fusion)
