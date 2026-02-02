-- 1. Trip Duration per Trip
SELECT 
    tc.transID,
    COALESCE(tc.corridorPK, 0) AS corridorPK,
    COALESCE(dc.corridorName, 'Unknown Corridor') AS corridorName,
    tc.tapInStopPK,
    tc.tapOutStopPK,
    TIMESTAMPDIFF(MINUTE, tc.tapInTime, tc.tapOutTime) AS trip_duration_min
FROM trip_complete tc
LEFT JOIN dim_corridor dc ON tc.corridorPK = dc.corridorPK
WHERE tc.tapInTime IS NOT NULL AND tc.tapOutTime IS NOT NULL;


-- 2. Trip Duration Summary per Corridor
SELECT 
	COALESCE(dc.corridorID) AS corrID,
    COALESCE(tc.corridorPK, 0) AS corridorPK,
    COALESCE(dc.corridorName, 'Unknown Corridor') AS corridorName,
    MIN(TIMESTAMPDIFF(MINUTE, tc.tapInTime, tc.tapOutTime)) AS min_duration,
    MAX(TIMESTAMPDIFF(MINUTE, tc.tapInTime, tc.tapOutTime)) AS max_duration,
    AVG(TIMESTAMPDIFF(MINUTE, tc.tapInTime, tc.tapOutTime)) AS avg_duration,
    STDDEV(TIMESTAMPDIFF(MINUTE, tc.tapInTime, tc.tapOutTime)) AS std_duration
FROM trip_complete tc
LEFT JOIN dim_corridor dc ON tc.corridorPK = dc.corridorPK
WHERE tc.tapInTime IS NOT NULL AND tc.tapOutTime IS NOT NULL
GROUP BY tc.corridorPK, dc.corridorName
ORDER BY avg_duration DESC;



-- 3. Trip Duration Summary per Corridor with Rush Hour Averages
SELECT 
	COALESCE(dc.corridorID) AS corrID,
    COALESCE(tc.corridorPK, 0) AS corridorPK,
    COALESCE(dc.corridorName, 'Unknown Corridor') AS corridorName,
    MIN(TIMESTAMPDIFF(MINUTE, tc.tapInTime, tc.tapOutTime)) AS min_duration,
    MAX(TIMESTAMPDIFF(MINUTE, tc.tapInTime, tc.tapOutTime)) AS max_duration,
    AVG(TIMESTAMPDIFF(MINUTE, tc.tapInTime, tc.tapOutTime)) AS avg_duration,
    STDDEV(TIMESTAMPDIFF(MINUTE, tc.tapInTime, tc.tapOutTime)) AS std_duration,
    AVG(CASE 
            WHEN HOUR(tc.tapInTime) BETWEEN 5 AND 7 
            THEN TIMESTAMPDIFF(MINUTE, tc.tapInTime, tc.tapOutTime) 
        END) AS morning_rush_avg,
    AVG(CASE 
            WHEN HOUR(tc.tapInTime) BETWEEN 16 AND 18 
            THEN TIMESTAMPDIFF(MINUTE, tc.tapInTime, tc.tapOutTime) 
        END) AS evening_rush_avg
FROM trip_complete tc
LEFT JOIN dim_corridor dc ON tc.corridorPK = dc.corridorPK
WHERE tc.tapInTime IS NOT NULL AND tc.tapOutTime IS NOT NULL
GROUP BY tc.corridorPK, dc.corridorName
ORDER BY evening_rush_avg asc;




