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



