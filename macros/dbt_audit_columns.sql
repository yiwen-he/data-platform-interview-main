{% macro dbt_audit_columns() %}
    cast('{{ run_started_at.isoformat() }}' as {{ dbt.type_timestamp() }}) as _dbt_run_started_at,
    cast('{{ invocation_id }}' as {{ dbt.type_string() }}) as _dbt_invocation_id
{% endmacro %}
