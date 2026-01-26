----- PASSENGER PROFILE -----
-- Who is riding the buses?

-- 0. Overview (count, max, min, avg)
SELECT
    COUNT(*) AS total_trips,
    MAX(trip_count) AS max_trips_per_passenger,
    MIN(trip_count) AS min_trips_per_passenger,
    ROUND(AVG(trip_count),2) AS avg_trips_per_passenger
FROM (
    SELECT payCardID, COUNT(*) AS trip_count
    FROM trip_complete
    GROUP BY payCardID
) AS passenger_trips;



-- 1. Total trips by gender distribution
SELECT payCardSex, COUNT(*) AS total_trips
FROM trip_complete tc
JOIN dim_passenger dp ON tc.payCardID = dp.payCardID
GROUP BY payCardSex
ORDER BY total_trips DESC;

-- 2. Total trips by age distribution
SELECT 
    FLOOR(YEAR(CURDATE()) - dp.payCardBirthYear) AS age,
    COUNT(*) AS total_trips
FROM trip_complete tc
JOIN dim_passenger dp ON tc.payCardID = dp.payCardID
WHERE dp.payCardBirthYear IS NOT NULL
GROUP BY age
ORDER BY age;

-- 3. Total trips by bank 
SELECT payCardBank, COUNT(*) AS total_trips
FROM trip_complete tc
JOIN dim_passenger dp ON tc.payCardID = dp.payCardID
GROUP BY payCardBank
ORDER BY total_trips DESC;

-- 4. Top passenger (April 2023)
-- 4.1 by total trips made
SELECT dp.payCardID, dp.payCardName, COUNT(*) AS trip_count
FROM trip_complete tc
JOIN dim_passenger dp ON tc.payCardID = dp.payCardID
GROUP BY dp.payCardID, dp.payCardName
ORDER BY trip_count DESC
LIMIT 10;

-- 4.2 by average weekly trips
SELECT 
    dp.payCardID,
    dp.payCardName,
    COUNT(*) / COUNT(DISTINCT YEARWEEK(tc.tapInTime, 1)) AS avg_weekly_trips
FROM trip_complete tc
JOIN dim_passenger dp ON tc.payCardID = dp.payCardID
GROUP BY dp.payCardID, dp.payCardName
ORDER BY avg_weekly_trips DESC
LIMIT 10; -- still the same people apparently



-- 5. Population pyramid
SELECT
    FLOOR(YEAR(CURDATE()) - dp.payCardBirthYear) AS age,
    dp.payCardSex,
    COUNT(DISTINCT dp.payCardID) AS passenger_count
FROM trip_complete tc
JOIN dim_passenger dp ON tc.payCardID = dp.payCardID
WHERE dp.payCardBirthYear IS NOT NULL
GROUP BY age, dp.payCardSex
ORDER BY age, dp.payCardSex;

SELECT
    CONCAT(FLOOR((YEAR(CURDATE()) - dp.payCardBirthYear)/5)*5, '-', 
           FLOOR((YEAR(CURDATE()) - dp.payCardBirthYear)/5)*5 + 4) AS age_group,
    dp.payCardSex,
    COUNT(DISTINCT dp.payCardID) AS passenger_count
FROM trip_complete tc
JOIN dim_passenger dp ON tc.payCardID = dp.payCardID
WHERE dp.payCardBirthYear IS NOT NULL
GROUP BY age_group, dp.payCardSex
ORDER BY age_group, dp.payCardSex;

-- 6. Trips by age group
SELECT
    CONCAT(FLOOR((YEAR(CURDATE()) - dp.payCardBirthYear)/5)*5, '-', 
           FLOOR((YEAR(CURDATE()) - dp.payCardBirthYear)/5)*5 + 4) AS age_group,
    COUNT(*) AS total_trips
FROM trip_complete tc
JOIN dim_passenger dp ON tc.payCardID = dp.payCardID
WHERE dp.payCardBirthYear IS NOT NULL
GROUP BY age_group
ORDER BY age_group;



