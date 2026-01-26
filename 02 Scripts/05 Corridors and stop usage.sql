----- CORRIDORS AND STOPS USAGE ----- 

-- 1. Busiest Tap-In Stops (by number of trips)
SELECT 
    tc.tapInStopPK,
    ds.stopName,
    COUNT(*) AS total_tapins
FROM trip_complete tc
JOIN dim_stop ds ON tc.tapInStopPK = ds.stopPK
GROUP BY tc.tapInStopPK, ds.stopName
ORDER BY total_tapins DESC
LIMIT 20;

-- 2. Busiest Tap-Out Stops (by number of trips)
SELECT 
    tc.tapOutStopPK,
    ds.stopName,
    COUNT(*) AS total_tapouts
FROM trip_complete tc
JOIN dim_stop ds ON tc.tapOutStopPK = ds.stopPK
GROUP BY tc.tapOutStopPK, ds.stopName
ORDER BY total_tapouts DESC
LIMIT 20;

-- 3. Busiest Corridors by Direction
SELECT 
    tc.corridorPK,
    COALESCE(dc.corridorName, 'Unknown Corridors') AS corridornames,
    tc.direction,
    COUNT(*) AS total_trips
FROM trip_complete tc
JOIN dim_corridor dc ON tc.corridorPK = dc.corridorPK
GROUP BY tc.corridorPK, dc.corridorName, tc.direction
ORDER BY total_trips DESC;

-- direction aggregated
SELECT 
    tc.corridorPK,
    dc.corridorName,
    COUNT(*) AS total_trips
FROM trip_complete tc
JOIN dim_corridor dc ON tc.corridorPK = dc.corridorPK
GROUP BY tc.corridorPK, dc.corridorName
ORDER BY total_trips DESC;


-- 4. Stop Usage per Corridor (busiest stop within each corridor)
SELECT 
    cs.corridorPK,
    dc.corridorName,
    tc.tapInStopPK AS stopPK,
    ds.stopName,
    COUNT(*) AS total_tapins
FROM trip_complete tc
JOIN corridor_stop cs ON tc.tapInStopPK = cs.stopPK AND tc.corridorPK = cs.corridorPK
JOIN dim_corridor dc ON cs.corridorPK = dc.corridorPK
JOIN dim_stop ds ON tc.tapInStopPK = ds.stopPK
GROUP BY cs.corridorPK, dc.corridorName, tc.tapInStopPK, ds.stopName
ORDER BY total_tapins DESC;

-- 5. Top Stop-to-Stop Trips (OD by corridor)
SELECT 
    tc.corridorPK,
    dc.corridorName,
    tc.tapInStopPK AS origin_stopPK,
    ds1.stopName AS origin_stop,
    tc.tapOutStopPK AS dest_stopPK,
    ds2.stopName AS dest_stop,
    COUNT(*) AS total_trips
FROM trip_complete tc
JOIN dim_corridor dc ON tc.corridorPK = dc.corridorPK
JOIN dim_stop ds1 ON tc.tapInStopPK = ds1.stopPK
JOIN dim_stop ds2 ON tc.tapOutStopPK = ds2.stopPK
GROUP BY tc.corridorPK, origin_stopPK, dest_stopPK, dc.corridorName, ds1.stopName, ds2.stopName
ORDER BY total_trips DESC
LIMIT 20;

-- 6. Top OD Pairs
SELECT 
    tc.tapInStopPK AS origin_stopPK,
    ds1.stopName AS origin_stop,
    tc.tapOutStopPK AS dest_stopPK,
    ds2.stopName AS dest_stop,
    COUNT(*) AS total_trips
FROM trip_complete tc
JOIN dim_stop ds1 ON tc.tapInStopPK = ds1.stopPK
JOIN dim_stop ds2 ON tc.tapOutStopPK = ds2.stopPK
WHERE tc.tapInStopPK IS NOT NULL AND tc.tapOutStopPK IS NOT NULL
GROUP BY origin_stopPK, dest_stopPK, origin_stop, dest_stop
ORDER BY total_trips DESC
LIMIT 20;

-- 7. tap-in vs tap-out per stops.
SELECT 
    ds.stopPK,
    ds.stopName,
    COALESCE(tc_in.total_tapins, 0) AS total_tapins,
    COALESCE(tc_out.total_tapouts, 0) AS total_tapouts
FROM dim_stop ds
LEFT JOIN (
    SELECT 
        tapInStopPK AS stopPK,
        COUNT(*) AS total_tapins
    FROM trip_complete
    WHERE tapInStopPK IS NOT NULL
    GROUP BY tapInStopPK
) tc_in ON ds.stopPK = tc_in.stopPK
LEFT JOIN (
    SELECT 
        tapOutStopPK AS stopPK,
        COUNT(*) AS total_tapouts
    FROM trip_complete
    WHERE tapOutStopPK IS NOT NULL
    GROUP BY tapOutStopPK
) tc_out ON ds.stopPK = tc_out.stopPK
ORDER BY total_tapins DESC;
