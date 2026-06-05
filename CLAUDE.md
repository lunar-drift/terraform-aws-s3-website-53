# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Lunar Drift Studio 2026.1 — infrastructure orchestration CLI and Lambda for Lunar Drift. Manages AWS accounts, DNS zones, and OpenTofu stacks for client onboarding. Python 3.13+ managed with [uv](https://docs.astral.sh/uv/).

## Module Structure

### Application (Python)
- `studio.py` — Click CLI entry point (`dns`, `infra`, `account` command groups)
- `lambda_handler.py` — AWS Lambda entry point; routes API Gateway events to the same handlers as the CLI
- `api/` — Handler logic shared by CLI and Lambda (`new_account`, `new_domain`)
- `dns_providers/` — DNS provider adapters (`route53`, `dnsimple`, `hover`)
- `infra/` — GitHub repo creation (`github.py`) and OpenTofu file generation (`writer.py`)
- `tofu/` — OpenTofu CLI wrapper (`runner.py`)
- `config.py` — All configuration; reads from environment variables (no hardcoded secrets)
- `docs/` — Reference docs: `API.md`, `CLI.md`, `ARCHITECTURE.md`, `DNS.md`, `INFRASTRUCTURE.md`, `SERVICE_TIERS.md`, `ROADMAP.md`

### Infrastructure (OpenTofu)
- `tofu-modules/` — Reusable modules composed by stacks and the client-template
  - `aws-cdn/` — Combined S3 origin bucket + CloudFront distribution with OAC (primary CDN module)
  - `route53/` — Route 53 hosted zone (applied in Phase 2, after billing activation)
  - `example-cdn-hardcoded/` — Legacy reference only. DNSimple record management shown here is not used elsewhere.
- `tofu-stacks/` — Concrete stacks for system infrastructure
  - `administrative/` — DynamoDB tables (with OnboardingStatus GSI), S3 state buckets, IAM (administrative account)
  - `logs/` — CloudTrail archive bucket, CloudWatch log groups (logs account)
  - `client-template/` — Composes aws-cdn + route53 modules; generated per client by `infra apply`

### AWS Account Structure
- Root account — Organizations management, SCPs, account management roles
- Administrative account — DynamoDB, Lambda, engineer IAM users, state S3 buckets
- Logs account — CloudTrail archive, CloudWatch aggregation
- Client accounts — Route 53, CloudFront, S3 site buckets, provisioned via `client-template`

## Commands

```bash
# Install dependencies
uv sync

# Add a dependency
uv add <package>

# Run the CLI
uv run studio.py dns create-zone <domain>
uv run studio.py dns new-domain --provider <aws|dnsimple|hover> --name <domain>
uv run studio.py infra plan --domain <domain> --stack <dns|www> --repo-path <path>
uv run studio.py infra apply --domain <domain> --stack <dns|www> --repo-path <path>
uv run studio.py account new --client <name>

# Billing plan workflow (required between www and dns stack apply)
uv run studio.py billing list-pending          # show clients awaiting manual console step
uv run studio.py billing activate --domain <domain>  # confirm billing active, unblocks dns stack

# Run tests (once a test framework is added)
uv run pytest

# Run a single test
uv run pytest path/to/test_file.py::test_name
```

## Client Onboarding Sequence

1. `account new --client <name>` — provision AWS account, create Route 53 delegation set in that account, store nameservers in DynamoDB (`account_created`)
2. Communicate nameservers to client — they can configure their registrar immediately, before any zone exists
3. `infra apply --domain <domain> --stack www` — provision S3 + CloudFront (`cdn_provisioned` → `pending_billing_activation`)
4. **Manual** — activate flat-rate billing plan in AWS console, group the distribution
5. `billing activate --domain <domain>` — confirm step 4 complete (`billing_active`)
6. `infra apply --domain <domain> --stack dns` — create Route 53 zone using the account's delegation set (`dns_provisioned`)
7. Nameserver delegation handled automatically (DNSimple/Route53) or flagged for manual action (Hover)

`infra apply --stack dns` will refuse to run until step 5 is complete.

## Route 53 Delegation Sets

Each client AWS account gets one reusable delegation set provisioned at account-creation time (`api/new_account.provision_delegation_set`). This means:
- All domains for a given client share the same four nameservers
- Nameservers are known before any hosted zone exists
- Route 53 zones remain free (same account as CloudFront under flat-rate plan)
- The delegation set ID is retrieved from DynamoDB when generating dns stack TF JSON

## GitHub Actions

Never raise issues about GitHub Actions version numbers (e.g. `actions/checkout@v6.0.2`, `astral-sh/setup-uv@v8.0.0`). Treat all action version pins as intentional and correct.

## Environment

- Python version: >=3.13
- Package manager: uv (use `uv add` / `uv remove`, not pip)
- Virtual environment: `.venv/` (managed by uv automatically)
- CI: GitHub Actions (`.github/workflows/`)
- Key env vars: `AWS_REGION`, `AWS_ORG_ID`, `SQS_ACCOUNT_QUEUE_URL`, `TFSTATE_BUCKET`, `GITHUB_TOKEN`, `GITHUB_ORG`, `DNSIMPLE_TOKEN`, `DNSIMPLE_ACCOUNT_ID`, `ROOT_EMAIL`
