{% test tenant_scoped_relationship(model, column_name, to, field) %}

-- A normal relationships test can match the entity ID while overlooking a
-- tenant mismatch. This test treats tenant_id as part of every relationship.
select
    child_relation.tenant_id,
    child_relation.{{ column_name }}
from {{ model }} as child_relation
left join {{ to }} as parent_relation
    on child_relation.tenant_id = parent_relation.tenant_id
    and child_relation.{{ column_name }} = parent_relation.{{ field }}
where child_relation.tenant_id is not null
    and child_relation.{{ column_name }} is not null
    and parent_relation.{{ field }} is null

{% endtest %}
