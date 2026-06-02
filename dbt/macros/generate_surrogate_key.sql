{% macro generate_surrogate_key(column_list) %}
    {{ dbt_utils.generate_surrogate_key(column_list) }}
{% endmacro %}


{% macro performance_tier(revenue_col) %}
    case
        when {{ revenue_col }} > 10000 then 'high'
        when {{ revenue_col }} >= 2000  then 'medium'
        else 'low'
    end
{% endmacro %}
