SELECT
    council_district AS council_district_id,
    CASE council_district
        WHEN 1  THEN 'District 1'
        WHEN 3  THEN 'District 3'
        WHEN 5  THEN 'District 5'
        WHEN 8  THEN 'District 8'
        WHEN 9  THEN 'District 9'
        WHEN 10 THEN 'District 10'
    END AS district_name
FROM (
    SELECT DISTINCT council_district
    FROM {{ ref('station_snapshot') }}
    WHERE council_district IS NOT NULL
        AND dbt_valid_to IS NULL
)