----- TEMPORAL TRAFFIC PATTERNS -----

-- 1. Trips by Hour of Day
SELECT 
    HOUR(tapInTime) AS hour_of_day,
    COUNT(*) AS total_trips
FROM trip_complete
WHERE tapInTime IS NOT NULL
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- 2. Trips by Day of Week
SELECT 
    DAYOFWEEK(tapInTime) AS day_of_week,  -- 1 = Sunday, 7 = Saturday
    COUNT(*) AS total_trips
FROM trip_complete
WHERE tapInTime IS NOT NULL
GROUP BY day_of_week
ORDER BY day_of_week;

-- 3. Trips by Hour and Day of Week
SELECT 
    DAYOFWEEK(tapInTime) AS day_of_week,
    HOUR(tapInTime) AS hour_of_day,
    COUNT(*) AS total_trips
FROM trip_complete
WHERE tapInTime IS NOT NULL
GROUP BY day_of_week, hour_of_day
ORDER BY day_of_week, hour_of_day;

-- 4. Trips by Day (Date)
SELECT 
    DATE(tapInTime) AS trip_date,
    COUNT(*) AS total_trips
FROM trip_complete
WHERE tapInTime IS NOT NULL
GROUP BY trip_date
ORDER BY trip_date;


