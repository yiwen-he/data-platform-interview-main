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

_List your models and the grain of each. e.g. "`fct_ticket_sales` — one row
per ticket."_

## Assumptions

_What did you assume about ambiguous or messy data, and why?_

## Reconciliation

_Did your T1 net revenue match Finance's `$271.00`? If not, what was the gap and what caused it? What did you conclude about T2, and what would you need to trust a T2 number?_

## Data I would question

_Anything you found that looks wrong, contradictory, or impossible across the source tables, and what you'd ask the source-system owners._

## Trade-offs

_What did you deliberately simplify or leave out given the time budget?_

## How I would productionise this

_CI/CD, environments, scheduling, monitoring, deployment controls._

## What I would do with more time

_The honest "next 5 things" list._
