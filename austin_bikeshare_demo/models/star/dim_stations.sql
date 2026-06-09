SELECT
    s.station_id,
    s.name,
    s.status,
    s.location,
    s.address,
    s.alternate_name,
    s.city_asset_number,
    s.number_of_docks,
    s.footprint_length,
    s.footprint_width,
    s.notes,
    s.image,
    s.modified_date,
    cd.council_district_id,
    pt.property_type_id,
    pw.power_type_id,
    AVG(t.duration_minutes) * 60 AS avg_duration
FROM {{ ref('station_snapshot') }} AS s
LEFT JOIN {{ ref('dim_council_district') }} AS cd
    ON s.council_district = cd.council_district_id
LEFT JOIN {{ ref('dim_property_type') }} AS pt
    ON s.property_type = pt.property_type_name
LEFT JOIN {{ ref('dim_power_type') }} AS pw
    ON s.power_type = pw.power_type_name
LEFT JOIN {{ source('austin_bikeshare', 'bikeshare_trips') }} AS t
    ON s.station_id = t.start_station_id
WHERE CURRENT_TIMESTAMP > s.dbt_valid_from
    AND s.dbt_valid_to IS NULL
GROUP BY
    s.station_id, s.name, s.status, s.location, s.address,
    s.alternate_name, s.city_asset_number, s.number_of_docks,
    s.footprint_length, s.footprint_width, s.notes, s.image,
    s.modified_date, cd.council_district_id, pt.property_type_id,
    pw.power_type_id