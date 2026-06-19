# dbt Retail Pipeline

A production-style dbt project built on PostgreSQL, demonstrating a full analytics engineering workflow across isolated dev, QA, and production environments — all running locally via Docker

---

## Project Overview

This project models a retail business domain (customers, products, orders, payments, inventory, stores, and web activity) through a layered dbt architecture:

- **Staging** — light transformations on raw seed data, materialized as views
- **Dimensions** — conformed dimension tables (customers, products, dates, stores)
- **Facts** — grain-level fact tables (orders, order items)

---

## Environment Architecture

Three isolated PostgreSQL servers run via Docker Compose, one per environment:

| Environment | Docker Container | Port | Purpose                                     |
| ----------- | ---------------- | ---- | ------------------------------------------- |
| `dev`       | `pg_dev`         | 5441 | Active development, personal sandbox        |
| `qa`        | `pg_qa`          | 5442 | Integration testing, pre-release validation |
| `prod`      | `pg_prod`        | 5443 | Production data, clean schema names         |

> **Note:** Ports 5441–5443 are used to avoid conflict with a local PostgreSQL 18 installation on port 5432.

Schema naming behavior (controlled by `macros/generate_schema_name.sql`):

- **dev** — schemas are prefixed with the developer's `target.schema` value (e.g., `coryp_raw`, `coryp_staging`, `coryp_marts`) to prevent collisions if multiple developers share the server
- **qa / prod** — schemas use clean layer names only (`raw`, `staging`, `marts`)

## Schema Naming Strategy (Enterprise dbt Best Practice)

This project follows dbt Labs’ recommended pattern for developer‑specific schemas in dev and shared schemas in QA/Prod.

### Why developer-specific schemas?

From the official dbt documentation:

> “If you have multiple dbt users writing code, it often makes sense for each user to have their own development environment.  
> A pattern we've found useful is to set your dev target schema to be dbt\_<username>.”  
> — dbt Labs, Managing Environments  
> https://docs.getdbt.com/docs/deploy/deploy-environments

### How this project implements it

#### Schema name derivation

Two pieces work together to produce schema names:

1. **`dbt_project.yml`** assigns a `+schema` to each layer:

   | Layer      | `+schema` value | Models included    |
   | ---------- | --------------- | ------------------ |
   | seeds      | `raw`           | all seed CSVs      |
   | staging    | `staging`       | all `stg_*` models |
   | dimensions | `marts`         | all `dim_*` models |
   | facts      | `marts`         | all `fct_*` models |

2. **`macros/generate_schema_name.sql`** combines `target.schema` (set to `DBT_USER`) with the layer's `+schema` value — but only in dev. In QA and prod the layer name is used as-is:

   ```
   dev schema  =  target.schema  +  "_"  +  +schema value
               =  DBT_USER       +  "_"  +  layer
   ```

#### Resulting schemas per environment

| Environment | Database      | Schemas created                                            |
| ----------- | ------------- | ---------------------------------------------------------- |
| dev         | `retail_dev`  | `{DBT_USER}_raw`, `{DBT_USER}_staging`, `{DBT_USER}_marts` |
| qa          | `retail_qa`   | `raw`, `staging`, `marts`                                  |
| prod        | `retail_prod` | `raw`, `staging`, `marts`                                  |

### Developer workflow

Each developer sets:

```bash
export DBT_USER=<your_username>
```

Examples:

- `DBT_USER=coryp` → creates `coryp_raw`, `coryp_staging`, `coryp_marts` in `retail_dev`
- `DBT_USER=jdoe` → creates `jdoe_raw`, `jdoe_staging`, `jdoe_marts` in `retail_dev`
- `DBT_USER=alex_smith` → creates `alex_smith_raw`, `alex_smith_staging`, `alex_smith_marts` in `retail_dev`

This ensures complete isolation between developers working in parallel.

### CI workflow

GitHub Actions uses:

```bash
DBT_USER=ci
```

This ensures:

- CI builds never collide with developer builds
- CI has stable, predictable schemas: `ci_raw`, `ci_staging`, `ci_marts` in `retail_dev`
- PR validation is isolated and reproducible
- No developer-specific assumptions leak into automated builds

---

## Branch & Deployment Strategy

```
feature/xyz ──► develop ──► main
│             │          │
dev           qa        prod
```

| Branch      | Target Environment | Trigger                                 |
| ----------- | ------------------ | --------------------------------------- |
| `feature/*` | dev                | Local dbt runs by the developer         |
| `develop`   | qa                 | GitHub Actions on push/PR merge         |
| `main`      | prod               | GitHub Actions on PR merge from develop |

### Workflow

1. Create a `feature/` branch from `develop` for all new work
2. Run and test locally against the **dev** database
3. Open a PR into `develop` — GitHub Actions runs `dbt build` against **qa**
4. After QA passes, open a PR from `develop` into `main` — GitHub Actions runs `dbt build` against **prod**
5. Direct commits to `main` are not permitted

---

## Current Build Status

| Component                                                            | Status         |
| -------------------------------------------------------------------- | -------------- |
| Project scaffold (seeds, staging, facts, dimensions)                 | ✅ Complete    |
| Git repo with `main` / `develop` branch strategy                     | ✅ Complete    |
| Docker Compose — 3 isolated PostgreSQL 15 servers                    | ✅ Complete    |
| dbt profiles for dev / qa / prod                                     | ✅ Complete    |
| `dbt debug` passing on all 3 targets                                 | ✅ Complete    |
| GitHub Actions CI/CD workflows                                       | 🔜 In progress |
| Remaining dimension models (dim_customers, dim_products, dim_stores) | 🔜 Pending     |

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

**Local development** — copy the example profile to your personal dbt directory and set the required environment variables:

```bash
cp profiles.yml.example ~/.dbt/profiles.yml
export DBT_USER=<your_username>
export DEV_DB_PASSWORD=<password>
```

`~/.dbt/profiles.yml` lives outside the repository and is never committed.

**CI/CD** — GitHub Actions uses `.github/profiles/profiles.yml`, which is committed to the repository. All passwords are injected at runtime from GitHub Secrets via dbt's `env_var()` function — no real credentials are stored in source control.

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
│   ├── workflows/     # CI/CD: dbt build on develop (qa) and main (prod)
│   └── profiles/      # profiles.yml used by CI (credentials via env_var)
├── docker-compose.yml # 3 PostgreSQL containers
├── profiles.yml.example
└── dbt_project.yml
```

---

## Custom Tests

| Test                | Description                                  |
| ------------------- | -------------------------------------------- |
| `phone_format`      | Validates `999-999-9999` pattern             |
| `valid_us_state`    | Checks two-letter US state/Canadian province |
| `promo_code_format` | Validates promo code structure               |

---

## Quick Build Script

`run_dbt_build.bat` is a Windows convenience script for running `dbt build` locally with an explicit environment argument.  
The script **requires** one of the following environments:

- `dev`
- `qa`
- `prod`

### Usage

```bat
run_dbt_build.bat dev
run_dbt_build.bat qa
run_dbt_build.bat prod
```

### What the script does

When executed with a valid environment, the script:

- Validates that the environment argument is provided and is one of: `dev`, `qa`, `prod`
- Runs:

  ```bat
  dbt build --target <env>
  ```

- Creates a `logs/` directory if it does not already exist. Log files are excluded from version control. Only the most recent 5 logs are retained per environment.
- Redirects all output to a timestamped log file, e.g.:

  ```
  logs\dbt_build_QA_20260612-0930.log
  ```

- Prints the full log file path to the console when finished
- Exits with the same exit code as `dbt build` so calling processes or CI can detect failures

This provides a consistent, repeatable way to run dbt locally while keeping clean logs for debugging.

---

## Good Idea Pile:

- [About dbt Wizard CLI | dbt Developer Hub](https://docs.getdbt.com/docs/dbt-ai/about-dbt-wizard-cli?version=2.0&name=Fusion)
