----- PASSENGER -----


-- 1. Create passenger dimension table
CREATE TABLE dim_passenger (
    payCardID        BIGINT PRIMARY KEY,
    payCardBank      VARCHAR(50),
    payCardName      VARCHAR(50),
    payCardSex       VARCHAR(50),
    payCardBirthYear INT
);


-- 2. Populate passenger table from trip_complete
INSERT INTO dim_passenger (
    payCardID,
    payCardBank,
    payCardName,
    payCardSex,
    payCardBirthYear
)
SELECT
    payCardID,
    MAX(payCardBank) AS payCardBank,
    MAX(payCardName) AS payCardName,
    MAX(payCardSex) AS payCardSex,
    MAX(payCardBirthDate) AS payCardBirthYear
FROM trip_complete
WHERE payCardID IS NOT NULL
GROUP BY payCardID;

SELECT COUNT(*) FROM dim_passenger dp; -- 1988


----- STOPS -----

-- 1. Create stops dimension table
CREATE TABLE dim_stop (
    stopPK      INT AUTO_INCREMENT PRIMARY KEY,
    sourceStopID VARCHAR(50),                    -- original stop ID, can be NULL
    stopName    VARCHAR(50) NOT NULL,
    stopLat     DOUBLE NOT NULL,
    stopLon     DOUBLE NOT NULL,
    UNIQUE KEY uq_stop_name_lat_lon (stopName, stopLat, stopLon)
);

-- 2. Populate dim_stop from both tap-in and tap-out stops
INSERT INTO dim_stop (sourceStopID, stopName, stopLat, stopLon)
SELECT
    MAX(stopID) AS sourceStopID,   -- pick a non-null sourceStopID if exists
    stopName,
    stopLat,
    stopLon
FROM (
    SELECT tapInStops AS stopID, tapInStopsName AS stopName, tapInStopsLat AS stopLat, tapInStopsLon AS stopLon
    FROM trip_complete
    WHERE tapInStopsName IS NOT NULL AND tapInStopsLat IS NOT NULL AND tapInStopsLon IS NOT NULL

    UNION ALL

    SELECT tapOutStops AS stopID, tapOutStopsName AS stopName, tapOutStopsLat AS stopLat, tapOutStopsLon AS stopLon
    FROM trip_complete
    WHERE tapOutStopsName IS NOT NULL AND tapOutStopsLat IS NOT NULL AND tapOutStopsLon IS NOT NULL
) AS combined_stops
GROUP BY stopName, stopLat, stopLon;   -- merge rows with same name+lat+lon

SELECT count(*) FROM dim_stop ds; -- 3617

----- CORRIDOR -----

SELECT * FROM trip_complete tc WHERE tc.corridorName  LIKE 'Terminal Kampung Melayu - Kapin Raya';

-- 1. Create the corridor dimension table
CREATE TABLE dim_corridor (
    corridorPK INT AUTO_INCREMENT PRIMARY KEY,
    corridorID VARCHAR(50) NOT NULL,
    corridorName VARCHAR(64) NOT NULL
);

-- 2. Populate dim_corridor by merging rows 

INSERT INTO dim_corridor (corridorID, corridorName)
SELECT DISTINCT corridorID, corridorName
FROM trip_complete
WHERE corridorID IS NOT NULL AND corridorName IS NOT NULL;

/* The values for of the corridor colums are either 'ID missing, Name exist', 'ID exist, Name missing', or 'both exist'
 * so I'm trying to merge the rows to match and fill each other
 */

SELECT count(*) FROM dim_corridor; -- 221
SELECT COUNT(*) AS unique_pairs FROM (SELECT DISTINCT corridorID, corridorName FROM dim_corridor) AS t; -- 221



----- CONNECTING THE TABLES -----

-- 1. trip_complete to dim_passenger
ALTER TABLE trip_complete
ADD CONSTRAINT fk_trip_passenger
FOREIGN KEY (payCardID)
REFERENCES dim_passenger(paycardID)
ON UPDATE CASCADE
ON DELETE SET NULL;


-- 2. trip_complete to dim_stop

-- 2.1 Add surrogate key columns for tap-in and tap-out stops

ALTER TABLE trip_complete
ADD COLUMN tapInStopPK INT,
ADD COLUMN tapOutStopPK INT;

-- 2.2 Populate surogate keys
-- 2.2.1 Tap In
UPDATE trip_complete tc
LEFT JOIN dim_stop ds_in
       ON tc.tapInStopsName = ds_in.stopName
      AND tc.tapInStopsLat = ds_in.stopLat
      AND tc.tapInStopsLon = ds_in.stopLon
SET tc.tapInStopPK = ds_in.stopPK;

-- 2.2.2 Tap Out
UPDATE trip_complete tc
LEFT JOIN dim_stop ds_out
       ON tc.tapOutStopsName = ds_out.stopName
      AND tc.tapOutStopsLat = ds_out.stopLat
      AND tc.tapOutStopsLon = ds_out.stopLon
SET tc.tapOutStopPK = ds_out.stopPK;

-- 2.3 Add foreign key constaint
ALTER TABLE trip_complete
ADD CONSTRAINT fk_trip_tapin_stop
FOREIGN KEY (tapInStopPK) REFERENCES dim_stop(stopPK)
ON DELETE SET NULL;

ALTER TABLE trip_complete
ADD CONSTRAINT fk_trip_tapout_stop
FOREIGN KEY (tapOutStopPK) REFERENCES dim_stop(stopPK)
ON DELETE SET NULL;

-- 3. trip_complete to dim_corridor
-- 3.1 add column
ALTER TABLE trip_complete
ADD COLUMN corridorPK INT AFTER payCardBirthDate;

-- 3.2 Populate corridorPK
UPDATE trip_complete tc
LEFT JOIN dim_corridor dc
       ON dc.corridorID = tc.corridorID
          OR dc.corridorName = tc.corridorName
SET tc.corridorPK = dc.corridorPK
WHERE tc.corridorID IS NOT NULL OR tc.corridorName IS NOT NULL;

-- 3.3 foreign key
ALTER TABLE trip_complete
ADD CONSTRAINT fk_trip_corridor
FOREIGN KEY (corridorPK)
REFERENCES dim_corridor(corridorPK)
ON DELETE SET NULL;


----- CREATING JUNCTION TABLE -----
-- 1. Create table

CREATE TABLE corridor_stop (
    corridorPK INT NOT NULL,
    stopPK     INT NOT NULL,
    PRIMARY KEY (corridorPK, stopPK),            -- prevent duplicates
    FOREIGN KEY (corridorPK) REFERENCES dim_corridor(corridorPK)
        ON DELETE CASCADE,
    FOREIGN KEY (stopPK) REFERENCES dim_stop(stopPK)
        ON DELETE CASCADE
);

-- 2. Populate the table
INSERT INTO corridor_stop (corridorPK, stopPK)
SELECT DISTINCT
       corridorPK,
       tapInStopPK AS stopPK
FROM trip_complete
WHERE corridorPK IS NOT NULL AND tapInStopPK IS NOT NULL
UNION
SELECT DISTINCT
       corridorPK,
       tapOutStopPK AS stopPK
FROM trip_complete
WHERE corridorPK IS NOT NULL AND tapOutStopPK IS NOT NULL;


----- DROPPING REDUNDANT COLUMN FROM trip_complete -----

ALTER TABLE trip_complete
DROP COLUMN paycardbank,
DROP COLUMN paycardname,
DROP COLUMN paycardsex,
DROP COLUMN paycardbirthdate,
DROP COLUMN tapInStops,
DROP COLUMN tapInStopsName,
DROP COLUMN tapInStopsLat,
DROP COLUMN tapInStopsLon,
DROP COLUMN tapOutStops,
DROP COLUMN tapOutStopsName,
DROP COLUMN tapOutStopsLat,
DROP COLUMN tapOutStopsLon,
DROP COLUMN corridorID,
DROP COLUMN corridorName;

-- check nulls

SELECT 
    COUNT(*) AS total_rows, -- 36556
    SUM(transID IS NULL) AS transID_nulls,
    SUM(payCardID IS NULL) AS payCardID_nulls,
    SUM(corridorPK IS NULL) AS corridorPK_nulls, -- 1078
    SUM(direction IS NULL) AS direction_nulls,
    SUM(stopStartSeq IS NULL) AS stopStartSeq_nulls,
    SUM(tapInTime IS NULL) AS tapInTime_nulls,
    SUM(stopEndSeq IS NULL) AS stopEndSeq_nulls,
    SUM(tapOutTime IS NULL) AS tapOutTime_nulls,
    SUM(payAmount IS NULL) AS payAmount_nulls, -- 968
    SUM(tapInStopPK IS NULL) AS tapInStopPK_nulls,
    SUM(tapOutStopPK IS NULL) AS tapOutStopPK_nulls
FROM trip_complete;

-- arranging the order
ALTER TABLE trip_complete
MODIFY COLUMN transID      VARCHAR(50) NOT NULL FIRST,
MODIFY COLUMN payCardID    BIGINT NULL AFTER transID,
MODIFY COLUMN corridorPK   INT NULL AFTER payCardID,
MODIFY COLUMN direction    TINYINT NOT NULL AFTER corridorPK,
MODIFY COLUMN tapInTime    DATETIME NULL AFTER direction,
MODIFY COLUMN tapInStopPK  INT NULL AFTER tapInTime,
MODIFY COLUMN stopStartSeq INT NULL AFTER tapInStopPK,
MODIFY COLUMN tapOutTime   DATETIME NULL AFTER stopStartSeq,
MODIFY COLUMN tapOutStopPK INT NULL AFTER tapOutTime,
MODIFY COLUMN stopEndSeq   INT NULL AFTER tapOutStopPK,
MODIFY COLUMN payAmount    INT NULL AFTER stopEndSeq;