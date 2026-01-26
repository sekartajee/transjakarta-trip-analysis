----- DATA CLEANING -----

ALTER TABLE trip ADD PRIMARY KEY (transID);

SELECT * FROM trip;

DESC trip;

-- checking row numbers
SELECT COUNT(*) FROM trip; -- 37900

-- checking nulls
SELECT
    COUNT(*) AS total_rows,
    SUM(transID IS NULL)              AS transID_nulls,
    SUM(payCardID IS NULL)            AS payCardID_nulls,
    SUM(payCardBank IS NULL)          AS payCardBank_nulls,
    SUM(payCardName IS NULL)          AS payCardName_nulls,
    SUM(payCardSex IS NULL)           AS payCardSex_nulls,
    SUM(payCardBirthDate IS NULL)     AS payCardBirthDate_nulls,
    SUM(corridorID IS NULL)           AS corridorID_nulls,
    SUM(corridorName IS NULL)         AS corridorName_nulls,
    SUM(direction IS NULL)            AS direction_nulls,
    SUM(tapInStops IS NULL)           AS tapInStops_nulls,
    SUM(tapInStopsName IS NULL)       AS tapInStopsName_nulls,
    SUM(tapInStopsLat IS NULL)        AS tapInStopsLat_nulls,
    SUM(tapInStopsLon IS NULL)        AS tapInStopsLon_nulls,
    SUM(stopStartSeq IS NULL)         AS stopStartSeq_nulls,
    SUM(tapInTime IS NULL)            AS tapInTime_nulls,
    SUM(tapOutStops IS NULL)          AS tapOutStops_nulls,
    SUM(tapOutStopsName IS NULL)      AS tapOutStopsName_nulls,
    SUM(tapOutStopsLat IS NULL)       AS tapOutStopsLat_nulls, -- 1344
    SUM(tapOutStopsLon IS NULL)       AS tapOutStopsLon_nulls, -- 1344
    SUM(stopEndSeq IS NULL)           AS stopEndSeq_nulls, -- 1344
    SUM(tapOutTime IS NULL)           AS tapOutTime_nulls,
    SUM(payAmount IS NULL)            AS payAmount_nulls -- 1007
FROM trip;



-- checking white space or empty strings
SELECT
    COUNT(*) AS total_rows,
    SUM(TRIM(transID) = '')          AS transID_empty,
    SUM(TRIM(payCardBank) = '')      AS payCardBank_empty,
    SUM(TRIM(payCardName) = '')      AS payCardName_empty,
    SUM(TRIM(payCardSex) = '')       AS payCardSex_empty,
    SUM(TRIM(corridorID) = '')       AS corridorID_empty,  -- 1257
    SUM(TRIM(corridorName) = '')     AS corridorName_empty, -- 1930
    SUM(TRIM(tapInStops) = '')       AS tapInStops_empty, -- 1213
    SUM(TRIM(tapInStopsName) = '')   AS tapInStopsName_empty,
    SUM(TRIM(tapInTime) = '')        AS tapInTime_empty,
    SUM(TRIM(tapOutStops) = '')      AS tapOutStops_empty, -- 2289
    SUM(TRIM(tapOutStopsName) = '')  AS tapOutStopsName_empty, -- 1344
    SUM(TRIM(tapOutTime) = '')       AS tapOutTime_empty -- 1344
FROM trip;

-- cheking unique values
SELECT
    COUNT(DISTINCT transID)          AS transID_unique, -- 37900
    COUNT(DISTINCT payCardID)        AS payCardID_unique, -- 2000
    COUNT(DISTINCT payCardBank)      AS payCardBank_unique, -- 6
    COUNT(DISTINCT payCardName)      AS payCardName_unique, -- 1993
    COUNT(DISTINCT payCardSex)       AS payCardSex_unique, -- 2
    COUNT(DISTINCT payCardBirthDate) AS payCardBirthDate_unique, -- 67
    COUNT(DISTINCT corridorID)       AS corridorID_unique, -- 222
    COUNT(DISTINCT corridorName)     AS corridorName_unique, -- 217
    COUNT(DISTINCT direction)        AS direction_unique, -- 2
    COUNT(DISTINCT tapInStops)       AS tapInStops_unique, -- 2571
    COUNT(DISTINCT tapInStopsName)   AS tapInStopsName_unique, -- 2602
    COUNT(DISTINCT tapInStopsLat)    AS tapInStopsLat_unique, -- 2587
    COUNT(DISTINCT tapInStopsLon)    AS tapInStopsLon_unique, -- 2458
    COUNT(DISTINCT stopStartSeq)     AS stopStartSeq_unique, -- 67
    COUNT(DISTINCT tapInTime)        AS tapInTime_unique, -- 37079
    COUNT(DISTINCT tapOutStops)      AS tapOutStops_unique, -- 2231
    COUNT(DISTINCT tapOutStopsName)  AS tapOutStopsName_unique, -- 2249
    COUNT(DISTINCT tapOutStopsLat)   AS tapOutStopsLat_unique, -- 2237
    COUNT(DISTINCT tapOutStopsLon)   AS tapOutStopsLon_unique, -- 2139
    COUNT(DISTINCT stopEndSeq)       AS stopEndSeq_unique, -- 74
    COUNT(DISTINCT tapOutTime)       AS tapOutTime_unique, -- 35909
    COUNT(DISTINCT payAmount)        AS payAmount_unique -- 3
FROM trip;

-- checking duplicates
SELECT
    transID,
    payCardID,
    payCardBank,
    payCardName,
    payCardSex,
    payCardBirthDate,
    corridorID,
    corridorName,
    direction,
    tapInStops,
    tapInStopsName,
    tapInStopsLat,
    tapInStopsLon,
    stopStartSeq,
    tapInTime,
    tapOutStops,
    tapOutStopsName,
    tapOutStopsLat,
    tapOutStopsLon,
    stopEndSeq,
    tapOutTime,
    payAmount,
    COUNT(*) AS duplicate_count
FROM trip
GROUP BY
    transID,
    payCardID,
    payCardBank,
    payCardName,
    payCardSex,
    payCardBirthDate,
    corridorID,
    corridorName,
    direction,
    tapInStops,
    tapInStopsName,
    tapInStopsLat,
    tapInStopsLon,
    stopStartSeq,
    tapInTime,
    tapOutStops,
    tapOutStopsName,
    tapOutStopsLat,
    tapOutStopsLon,
    stopEndSeq,
    tapOutTime,
    payAmount
HAVING COUNT(*) > 1; -- no dupes


----- STANDARDISATION ----------------------------------------------------------------------------------------------

-- TRIMMING THE STRINGS --
UPDATE trip
SET
    transID = TRIM(transID),
    payCardBank = TRIM(payCardBank),
    payCardName = TRIM(payCardName),
    payCardSex = TRIM(payCardSex),
    corridorID = TRIM(corridorID),
    corridorName = TRIM(corridorName),
    tapInStops = TRIM(tapInStops),
    tapInStopsName = TRIM(tapInStopsName),
    tapInTime = TRIM(tapInTime),
    tapOutStops = TRIM(tapOutStops),
    tapOutStopsName = TRIM(tapOutStopsName),
    tapOutTime = TRIM(tapOutTime);

-- STADARDIZING TIME --
SELECT tapInTime, tapOutTime 
FROM trip
LIMIT 10;

-- set white space to null
UPDATE trip
SET
    tapOutTime = NULLIF(TRIM(tapOutTime), ''),
    tapInTime  = NULLIF(TRIM(tapInTime), '');

-- changing data type
ALTER TABLE trip
MODIFY tapInTime  DATETIME NULL,
MODIFY tapOutTime DATETIME NULL;

-- STANDARDISING StopSeq data type --
ALTER TABLE trip
MODIFY stopEndSeq INT NULL; -- no reason for it to be double

-- STANDARDISING payAmount data type
ALTER TABLE trip
MODIFY payAmount INT NULL;

-- CHANGING direction data type and adding comment
ALTER TABLE trip 
MODIFY direction TINYINT NOT NULL COMMENT '0 = Go, 1 = Back';



----- MODIFY NULLS AND WHITESPACE -----
-- corridorID 1257; corridorName 1930; tapInStops_empty 1213; tapOutStops 2289; tapOutStopsName_empty 1344 --

UPDATE trip
SET
  corridorID        = NULLIF(TRIM(corridorID), ''),
  corridorName      = NULLIF(TRIM(corridorName), ''),
  tapInStops        = NULLIF(TRIM(tapInStops), ''),
  tapOutStops       = NULLIF(TRIM(tapOutStops), ''),
  tapOutStopsName   = NULLIF(TRIM(tapOutStopsName), '')
WHERE
  corridorID IS NOT NULL
  OR corridorName IS NOT NULL
  OR tapInStops IS NOT NULL
  OR tapOutStops IS NOT NULL
  OR tapOutStopsName IS NOT NULL;

-- checking updated NULL values
/*
corridorID_nulls, -- 1257
corridorName_nulls, -- 1930
tapInStops_nulls, -- 1213
tapOutStops_nulls, -- 2289
tapOutStopsName_nulls, -- 1344
tapOutStopsLat_nulls, -- 1344
tapOutStopsLon_nulls, -- 1344
stopEndSeq_nulls, -- 1344
tapOutTime_nulls, -- 1344
payAmount_nulls -- 1007
 */

-- dropping records where tapOutTime is NULL cause it indicates incomplete trip
-- I'll create a new table for the complete trip
CREATE TABLE trip_complete AS
SELECT *
FROM trip
WHERE tapOutTime IS NOT NULL;

SELECT COUNT(*) AS rownum -- 36556 rows
FROM trip_complete;

ALTER TABLE trip_complete
ADD PRIMARY KEY (transID);












