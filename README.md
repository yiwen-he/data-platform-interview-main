# Data Engineering Take Home Exercise

We care about your judgement and how you communicate it far more than about volume of output.

## Time and logistics

- Please spend no more than 2 hours of focused work. If you run out of time, stop and write down what you would have done next; that note is part of what we score.
- Submit as a Git repo (preferred) or a zip.

## Using AI

Use whatever AI tooling you would normally use day to day.

## The scenario

We run a multi-tenant ticketing platform. Each tenant sells tickets to events. Raw operational data lands in our warehouse. We want trusted data products that can power:

- internal analytics,
- tenant-facing reporting,
- Snowflake data shares,
- usage-based billing, and
- natural-language / AI querying over curated data.

The direction is Snowflake + dbt, or an equivalent code-first modelling approach. For this exercise you will work locally with dbt + DuckDB.

The raw data lives in [`/seeds`](./seeds) as CSVs: tenants, venues, events, customers, orders, tickets, refunds, and gate scans. It is realistic data, which means it is messy. Part of the exercise is noticing how.

Some business context - metric rules, currencies and Finance's reconciliation figures is in [`docs/BUSINESS_CONTEXT.md`](./docs/BUSINESS_CONTEXT.md).

## Your task

Build a small, code-first project that turns this raw data into trusted, reusable models that a BI tool or a data share could sit on top of. Your models should let someone reliably answer one question:

* Net revenue per tenant and per event.

Then reconcile your net revenue to the Finance figures in [`docs/BUSINESS_CONTEXT.md`](./docs/BUSINESS_CONTEXT.md), and explain any difference.

You decide the layering, the grain of each model, the dimensions, and the
tests. We care more about why than about how much you produce.

## Deliverables

1. A runnable project. `make build` should load the data, build your models, and run your tests.
2. Your models, organised into layers, with the grain of each model stated (in `schema.yml` descriptions or comments).
3. Tests - schema and business-logic.
4. This README, completed.

---

## Quickstart

Requires Python 3.9+ and `make`.

```bash
make setup    # creates a virtualenv, installs dbt-duckdb, installs dbt packages
make build    # runs `dbt build` (seeds + models + tests)
make docs     # generate and serve the dbt docs site locally: visualises model/column descriptions, tests and lineage graphs.
```

Out of the box this loads the seeds and builds one example model (`stg_tenants`) so you can confirm the environment works. Replace or delete the example as you like.

Querying the DuckDB using dbt's built in query runner:

```
.venv/bin/dbt show --inline "select * from {{ ref('raw_orders') }}" --limit 50
```

---

## What we are assessing

- Modelling judgement - grain, facts vs dimensions, handling of edge cases.
- Engineering discipline - tests, structure, reproducibility.
- Tenant safety - Tenant A must never be able to see Tenant B's data.
- Pragmatism - sensible trade-offs given a 3-hour budget.
- AI usage - how you direct and, crucially, verify AI.
- Communication - how clearly you explain your decisions.

We are not assessing dashboards, exhaustive coverage, or polish for its own sake. A focused, well-reasoned partial solution beats a sprawling one.

---

# Your submission

> Fill in the sections below. Keep it concise.

## What I built

#### Seeds

- Added `_seeds.yml` to define seed files, columns, and tests

#### Staging

- Added 8 cleaned staging models, one for each raw seed, referenced via `ref()`
- Column value cleaned with functions such as `trim()`, `nullif()`, `upper()` where appropriate
- Deduplication with the existing available datatime column `created_at_utc`, pending confirmation from stakeholders on deterministic datetime column such as `updated_at` from source system
- Incoporate dbt audit columns such as `_dbt_run_started_at` and ` _dbt_invocation_id` through the use of macros
- Added `_staging.yml` to define staging models, columns, and tests
- `stg_customers` deliberately exposes only the non-PII fields needed to validate tenant ownership of orders and publish `dim_customer`

#### Intermediate

Added:
- 8 intermediate models transform cleaned staging models into reusable, tenant-safe models with conformed keys, validated relationships, and business attributes for downstream mart models and snapshots
- `int_tenant_currency` manually with one row per tenant with its configured home currency, the information is supplied by docs/BUSINESS_CONTEXT.md
- `int_completed_refunds_by_order` to aggregate completed refunds by tenant and order
- `int_date` to create one row per calendar date from 2023-01-01 through 2999-12-31 for reuse 
- `_intermediate.yml` to define intermediate models, columns, and tests

#### Mart models

Added:
- `dim_tenant` - One row per tenant, including its surrogate key, source tenant ID, tenant name, and configured home currency
- `dim_customer` - One row per tenant-scoped customer. Direct PII is omitted. Retains the customer key, source customer ID, country, and creation date 
- `dim_venue` - One row per tenant-scoped venue, containing reusable venue attributes such as name, city, timezone, and capacity
- `dim_event` - One row per tenant-scoped event, connected to its tenant, venue, and event date through conformed warehouse keys
- `dim_date` - Shared, non-tenant dimension with one row per calendar date from 2023-01-01 through 2999-12-31 for reuse
- `fct_ticket` - One row per tenant-scoped ticket, including its price, currency, status, and relationships to the order and event
- `fct_refund` - One row per tenant-scoped refund, including its amount, currency, status, and relationship to the related order
- `fct_event_entry` - One row per event-entry scan attempt, connected to the tenant, ticket, order, event, and scan date. Renamed from scan to event_entry to provide more clarity to business
- `fct_order_revenue` - Fact table on completed order, with gross revenue, platform fees, tax, completed refunds, and net revenue at the order grain
- `rpt_tenant_event_revenue` - Reporting table aggregates revenue per tenant, event, and currency
- `rpt_tenant_revenue` - Reporting table aggregates revenue per tenant and currency
- `_mart.yml` - Defines mart models, columns, and tests

### Snapshots

Added:
- `snap_order_status` — Tracks order status change as SCD2 history using dbt snapshots
- `snap_refund_status` — Tracks refund status change as SCD2 history using dbt snapshots
- `snap_ticket_status` — Tracks ticket status change as SCD2 history using dbt snapshots
- `_snapshots.yml` — Defines snapshot models

####  Macros

- `dbt_audit_columns` — macro to generate consistent dbt run-start and invocation metadata
- `test_tenant_scoped_relationship` — macro to validate relationships using both tenant and entity identifiers

#### Tests

- `test_no_refund_predates_order` — Detects refunds timestamped before their parent orders

#### Other changes

- `dbt_project` - Added date variables for data table creation, added schema configurations, and use warning as test defaults


## Assumptions

- For deduplication, the row with the latest `created_at_utc` is assumed to be the authoritative record. Deduplication uses `row_number()` odered by that timestamp descending. This is a temporary proxy for record recency becase no `updated_at` or warehouse ingestion timestamp is provided
- Entity IDs (such as customer id) are assumed to be tenant-scoped even though most happen to be globally unique in this sample
- The T1/USD and T2/GBP mappings in `BUSINESS_CONTEXT.md` are treated as the authoritative tenant configuration for this exercise. An intermediate table is created on this basis for fct table calculation
- A completed order is included in trusted revenue only when it is mapped to a known tenant, and its currency matches that tenant's configured home currency. Rows that fail these requirements are excluded rather than attributed or converted by inference

## Reconciliation

T1 reconciles exactly to Finance's **$271.00**:

- O1: `200 gross − 15 tax − 80 completed refunds = 105 USD`
- O2: `100 gross − 8 tax − 0 completed refunds = 92 USD`
- O3: Cancelled
- O7: Pending
- O8: `0 gross − 0 tax − 0 completed refunds = 0 USD`
- O10: `80 gross − 6 tax − 0 completed refunds = 74 USD`
- Tenant total: `105 + 92 + 74 = 271 USD`, matches Finance number of `0 USD`
- This can be confirmed within the mart table `rpt_tenant_revenue` where T1 reaches a net revenue amount of $271

The trusted net revenue for T2 is **410 GBP** from orders O4 and O9:
`550 gross - 40 tax - 100 completed refunds`. 
It cannot reconcill easily because:
- Order O5 is recorded in EUR despite T2's GBP home currency
- Order O6 and cannot be attributed to either T1 or T2
To trust a final T2 number, Finance/source owners must confirm O5's currency and FX treatment, establish O6's tenant through an authoritative source correction, and explain the O5 over-refund and O9 ticket-total difference

## Data I would question

- Refund `R1` appeared twice in the seed file. I would ask whether there is any known error in the landing process and if there is an ingestion metadata column that can provide a more robust deduplication order. This can be followed up with the source-system owners on an authoritative column such as `updated_at` for deterministic deduplication
- Refund `R4` predates order `O1`. I would ask whether this is a timestamp defect, an order migration, or an expected pre-order adjustment
- T2 order `O5` is in EUR although T2's documented home currency is GBP. Its refund has no currency, so I would ask for the authoritative currency and FX treatment before including it in a tenant total
- No exchange-rate table is supplied. If a currency other than the home currency of the tenant is accepted in the source system, we would require an exchange-rate table for the currency conversion
- Refund `R5` is 150 against order `O5` gross revenue of 100. I would ask whether refunds can include fees, multiple orders, or external adjustments
- Order `O6` and ticket `TK9` have no tenant ID. Their related records suggest T2, but that is not sufficient evidence for a tenant-facing data product
- Order `O9` has gross revenue of 250 but only 200 of ticket prices. I would ask whether order gross can include non-ticket products or whether a ticket is missing
- Scan `S6` refers to nonexistent ticket `TK999`. There are also scans of an exchanged ticket and a cancelled ticket, plus three scans for `TK1`. I would ask whether scans represent attempts or admissions and which scan is correct
- Venue `V2` has no timezone, preventing trustworthy local-time reporting for its events
- Customer email is repeated both within `T1` and across tenants, so it cannot be treated as a customer key or used for cross-tenant identity matching
- If the reporting is for tenant consumption directly, I would check with the tenant whether a conversion to their local time is needed
- Customer SCD2 history has not been implemented because direct PII such as email and full name is deliberately excluded from the current models. If historical customer attributes become a business requirement, I would add a targeted snapshot with appropriate privacy and access controls

## Trade-offs

- Direct customer PII (`email` and `full_name`) is omitted from `stg_customers` because the revenue use case does not need it. In production, raw PII would additionally be protected by restricted schemas, classification tags, masking policies, and audited roles; hashing alone would not make it non-sensitive
- Data-quality tests currently produce warnings so the supplied project can complete `dbt build`. However, warnings do not prevent downstream processing. In Production, critical tenant-isolation and currency-validation failures should be blocking errors, with invalid records quarantined before publication
- `tenant_scoped_relationship` was created to validate relationships using both tenant and entity identifiers, preventing records from different tenants being linked when they share the same entity ID
- `int_tenant_currency` is hard-coded based on the two mappings supplied in the business context. In Production this configuration should come from a governed reference table or tenant-management source

## How I would productionise this
- Replace CSV seeds with ingestion from source systems that captures reliable change timestamps and ingestion metadata
- Obtain and use the source system owned update/ingestion column for landing data deduplication  
- Improve the project’s metadata coverage by adding clear descriptions and data types for every column in the YAML files, making the models easier to understand, govern, and consume through dbt documentation
- Run `dbt build` and SQL linting in pull requests against an isolated CI schema, require review and pass all tests before merge
- Orchestrate dbt jobs based on ingestion load or business requirement with appropriate business tolling
- Build alerts on freshness, blocking test failures, warning-count changes, reconciliation drift. Create investigation runbooks, and process for notifying affected consumers
- Secure tenant reporting in Snowflake using row access policies and tenant-specific data shares. Allow tenants to access only their own published reports, and test that other tenants’ data and underlying tables remain inaccessible
- Treat this as a data product by adding an end-to-end architecture and lineage diagram, clear ownership and data contracts, metric definitions, freshness expectations, access controls, operational runbooks, and consumer-facing documentation

## What I would do with more time

- Improve the project’s metadata coverage by adding clear descriptions and data types for every column in the YAML files, making the models easier to understand, govern, and consume through dbt documentation
- Add governed exposures, ownership metadata, contracts, and role-based masking for any future customer data product
- Treat this as a data product by adding an end-to-end architecture and lineage diagram, clear ownership and data contracts, metric definitions, freshness expectations, access controls, operational runbooks, and consumer-facing documentation
- If production data load is in large volume, consider incremental loading to reduce processing time and warehouse costs, supported by reliable change-tracking fields, late-arriving data handling, and periodic full-refresh validation