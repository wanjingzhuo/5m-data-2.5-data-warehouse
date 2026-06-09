{% snapshot store_snapshot %}

{{
  config(
    target_schema='snapshots',
    unique_key='store_number',
    strategy='check',
    check_cols=['store_name', 'address', 'city', 'zip_code'],
  )
}}

WITH 
store AS (
    SELECT
        store_number,
        ANY_VALUE(store_name) store_name,
        ANY_VALUE(address) address,
        ANY_VALUE(city) city,
        REGEXP_REPLACE(ANY_VALUE(zip_code), r"\.0$", "") zip_code,
        ANY_VALUE(county_number) county_number,
        ANY_VALUE(county) county,
        date
    FROM
        {{ source('iowa_liquor_sales', 'sales') }}
    GROUP BY store_number, date
),
grouped_data AS (
    SELECT DISTINCT
        store_number,
        store_name,
        address,
        city,
        zip_code,
        county_number,
        county,
        FIRST_VALUE(date) OVER (PARTITION BY store_number, store_name, address, city, zip_code, county_number, county ORDER BY date) start_date,
        LAST_VALUE(date) OVER (PARTITION BY store_number, store_name, address, city, zip_code, county_number, county ORDER BY date) end_date,
    FROM
        store
    QUALIFY RANK() OVER (PARTITION BY store_number, store_name, address, city, zip_code, county_number, county ORDER BY date) = 1
)
SELECT
    store_number,
    store_name,
    address,
    city,
    zip_code,
    county_number,
    county,
    CAST(start_date AS TIMESTAMP) start_at,
    CAST(LEAD(start_date) OVER (PARTITION BY store_number ORDER BY start_date) AS TIMESTAMP) as end_at,
    IF(LEAD(start_date) OVER (PARTITION BY store_number ORDER BY start_date) IS NULL, CURRENT_TIMESTAMP(), NULL) as updated_at,
FROM
    grouped_data
ORDER BY store_number, start_at, end_at

{% endsnapshot %}