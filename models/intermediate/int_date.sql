{{ config(materialized='view') }}

-- Grain: one row per calendar date.

with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('" ~ var('dim_date_start_date') ~ "' as date)",
        end_date="cast('" ~ var('dim_date_end_date_exclusive') ~ "' as date)"
    ) }}
)

select
    cast(
        extract(year from date_day) * 10000
        + extract(month from date_day) * 100
        + extract(day from date_day)
        as integer
    ) as date_key,
    cast(date_day as date) as date_day,
    cast(extract(day from date_day) as integer) as day_of_month,
    dayname(date_day) as day_name,
    cast(extract(week from date_day) as integer) as week_of_year,
    cast(extract(month from date_day) as integer) as month_number,
    monthname(date_day) as month_name,
    cast(extract(quarter from date_day) as integer) as quarter_number,
    cast(extract(year from date_day) as integer) as year_number,
    cast(date_trunc('week', date_day) as date) as week_start_date,
    cast(date_trunc('month', date_day) as date) as month_start_date,
    cast(date_trunc('quarter', date_day) as date) as quarter_start_date,
    cast(date_trunc('year', date_day) as date) as year_start_date,
    lower(dayname(date_day)) in ('saturday', 'sunday') as is_weekend
from date_spine
