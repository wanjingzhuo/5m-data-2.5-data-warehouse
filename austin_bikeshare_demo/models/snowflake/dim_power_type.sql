SELECT
    ROW_NUMBER() OVER (ORDER BY power_type) AS power_type_id,
    power_type AS power_type_name
FROM (
    SELECT DISTINCT power_type
    FROM {{ ref('station_snapshot') }}
    WHERE power_type IS NOT NULL
        AND dbt_valid_to IS NULL
)