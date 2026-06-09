SELECT
    ROW_NUMBER() OVER (ORDER BY property_type) AS property_type_id,
    property_type AS property_type_name
FROM (
    SELECT DISTINCT property_type
    FROM {{ ref('station_snapshot') }}
    WHERE property_type IS NOT NULL
        AND dbt_valid_to IS NULL
)