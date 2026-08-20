select * from vehicle_details


--Total Records
SELECT COUNT(*) AS total_records
FROM vehicle_details;


-- Check duplicate registration numbers
SELECT Registration_Number, COUNT(*) AS count
FROM vehicle_details
GROUP BY registration_number
HAVING COUNT(*) > 1;




SELECT
    COUNT(*) AS total_rows,
    COUNT(emission_norm) AS emission_norm_present,
    COUNT(fuel_type_clean) AS fuel_type_present,
    COUNT(registration_date) AS registration_date_present
FROM vehicle_details;



-- DATA 2018-2024
-- Registrations by year
SELECT
    registration_year,
    COUNT(*) AS registrations
FROM vehicle_details
GROUP BY registration_year
ORDER BY registration_year;



-- Registration by month
SELECT
    registration_month,
    COUNT(*) AS registrations
FROM vehicle_details
GROUP BY registration_month
ORDER BY registration_month;


-- Registration by day of week
SELECT
    registration_dayofweek,
    COUNT(*) AS registrations
FROM vehicle_details
GROUP BY registration_dayofweek
ORDER BY registrations DESC;


-- Top 12 states
SELECT
    state_clean,
    COUNT(*) AS registrations
FROM vehicle_details
GROUP BY state_clean
ORDER BY registrations DESC
LIMIT 12;



-- State + vehicle category
SELECT
    state_clean,
    vehicle_category,
    COUNT(*) AS registrations
FROM vehicle_details
GROUP BY state_clean, vehicle_category
ORDER BY state_clean, registrations DESC;



-- State + fuel type
SELECT
    state_clean,
    fuel_type_clean,
    COUNT(*) AS vehicle_count
FROM vehicle_details
GROUP BY state_clean, fuel_type_clean
ORDER BY state_clean, vehicle_count DESC;



--  Fuel and EV analysis
-- Overall fuel distribution
-- -Consider for emission project

SELECT
    fuel_type_clean,
    COUNT(*) AS vehicle_count
FROM vehicle_details
GROUP BY fuel_type_clean
ORDER BY vehicle_count DESC;


-- EV registrations by year   (Are EV registrations increasing over time?)
SELECT
    registration_year,
    COUNT(*) AS ev_count
FROM vehicle_details
WHERE fuel_type_clean = 'EV'
GROUP BY registration_year
ORDER BY registration_year;


-- EV registrations by state
SELECT
    state_clean,
    COUNT(*) AS ev_count
FROM vehicle_details
WHERE fuel_type_clean = 'EV'
GROUP BY state_clean
ORDER BY ev_count DESC;


-- EV percentage by state  (Which states have the highest EV adoption rate in this dataset?)
-- better than just counting EVs.

SELECT
    state_clean,
    COUNT(*) AS total_vehicles,
    SUM(CASE WHEN fuel_type_clean = 'EV' THEN 1 ELSE 0 END) AS ev_vehicles,
    ROUND(
        100.0 * SUM(CASE WHEN fuel_type_clean = 'EV' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS ev_percentage
FROM vehicle_details
GROUP BY state_clean
ORDER BY ev_percentage DESC;




-- Emission-norm analysis
-- Consider
-- Overall emission norm distribution

SELECT
    emission_norm,
    COUNT(*) AS vehicle_count
FROM vehicle_details
GROUP BY emission_norm
ORDER BY vehicle_count DESC;




-- Emission norm by year
SELECT
    registration_year,
    emission_norm,
    COUNT(*) AS vehicle_count
FROM vehicle_details
GROUP BY registration_year, emission_norm
ORDER BY registration_year, emission_norm;


-- Emission norm by state
SELECT
    state_clean,
    emission_norm,
    COUNT(*) AS vehicle_count
FROM vehicle_details
GROUP BY state_clean, emission_norm
ORDER BY state_clean, vehicle_count DESC;


-- Find suspicious BS4 registrations

-- Already did this in Python.


SELECT
    registration_number,
    registration_date,
    registration_year,
    state_clean,
    rto_office,
    emission_norm
FROM vehicle_details
WHERE emission_norm = 'BS4'
  AND registration_date > DATE '2021-04-01';

-- Count it 
SELECT COUNT(*) AS suspicious_bs4_count
FROM vehicle_details
WHERE emission_norm = 'BS4'
  AND registration_date > DATE '2021-04-01';


-- Top manufacturers
SELECT
    manufacturer_brand,
    COUNT(*) AS vehicle_count
FROM vehicle_details
GROUP BY manufacturer_brand
ORDER BY vehicle_count DESC
LIMIT 10;


-- Manufacturer + fuel type    This could reveal: Which manufacturers are associated with EVs, petrol, diesel, etc.?
SELECT
    manufacturer_brand,
    fuel_type_clean,
    COUNT(*) AS vehicle_count
FROM vehicle_details
GROUP BY manufacturer_brand, fuel_type_clean
ORDER BY manufacturer_brand, vehicle_count DESC;




-- Vehicle category analysis

SELECT
    vehicle_category,
    COUNT(*) AS vehicle_count
FROM vehicle_details
GROUP BY vehicle_category
ORDER BY vehicle_count DESC;


-- Vehicle category + fuel   (Are EVs more common in 2-wheelers or 4-wheelers?)
SELECT
    vehicle_category,
    fuel_type_clean,
    COUNT(*) AS vehicle_count
FROM vehicle_details
GROUP BY vehicle_category, fuel_type_clean
ORDER BY vehicle_category, vehicle_count DESC;



-- 9. Engine analysis
-- Average engine CC by fuel


SELECT
    fuel_type_clean,
    ROUND(AVG(engine_cc), 2) AS avg_engine_cc
FROM vehicle_details
WHERE engine_cc IS NOT NULL
GROUP BY fuel_type_clean;

--IMP
SELECT
    vehicle_category,
    ROUND(AVG(engine_cc), 2) AS avg_engine_cc
FROM vehicle_details
WHERE engine_cc IS NOT NULL
GROUP BY vehicle_category;


-- Engine size groups
-- Create categories:

SELECT
    CASE
        WHEN engine_cc = 0 THEN 'EV'
        WHEN engine_cc < 1000 THEN 'Below 1000 CC'
        WHEN engine_cc < 1500 THEN '1000-1499 CC'
        WHEN engine_cc < 2000 THEN '1500-1999 CC'
        ELSE '2000+ CC'
    END AS engine_category,
    COUNT(*) AS vehicle_count
FROM vehicle_details
GROUP BY engine_category
ORDER BY vehicle_count DESC;



-- Vehicle age analysis
-- Average vehicle age by state

SELECT
    state_clean,
    ROUND(AVG(vehicle_age_years), 2) AS avg_vehicle_age
FROM vehicle_details
GROUP BY state_clean
ORDER BY avg_vehicle_age DESC;



-- Age groups
SELECT
    CASE
        WHEN vehicle_age_years <= 2 THEN '0-2 Years'
        WHEN vehicle_age_years <= 5 THEN '3-5 Years'
        WHEN vehicle_age_years <= 10 THEN '6-10 Years'
        ELSE '10+ Years'
    END AS age_group,
    COUNT(*) AS vehicle_count
FROM vehicle_details
GROUP BY age_group
ORDER BY vehicle_count DESC;


-- RTO analysis

-- Extracted RTO information using Python.
-- Top RTO offices

SELECT
    rto_office,
    COUNT(*) AS vehicle_count
FROM vehicle_details
GROUP BY rto_office
ORDER BY vehicle_count DESC
LIMIT 15;

-- RTO state prefix distribution
SELECT
    rto_state_prefix,
    COUNT(*) AS vehicle_count
FROM vehicle_details
GROUP BY rto_state_prefix
ORDER BY vehicle_count DESC;






-- ICE vs EV
SELECT
    CASE
        WHEN fuel_type_clean = 'EV' THEN 'Electric'
        ELSE 'ICE'
    END AS propulsion_type,
    COUNT(*) AS vehicle_count
FROM vehicle_details
GROUP BY propulsion_type;




SELECT
    state_clean,
    fuel_type_clean,
    emission_norm,
    COUNT(*) AS vehicle_count,
    ROUND(AVG(engine_cc), 2) AS avg_engine_cc,
    ROUND(AVG(vehicle_age_years), 2) AS avg_vehicle_age
FROM vehicle_details
WHERE fuel_type_clean <> 'EV'
GROUP BY
    state_clean,
    fuel_type_clean,
    emission_norm
ORDER BY vehicle_count DESC;


SELECT COUNT(*) AS total_ev_vehicles
FROM vehicle_details
WHERE UPPER(TRIM(fuel_type_clean)) = 'EV';











