---Show full view of all data, even if unmatched
---(FULL OUTER JOIN)

SELECT *
FROM Sales_Analysis.Dataset.BrightTV_UserProfiles u
FULL OUTER JOIN Sales_Analysis.Dataset.BrightTV_Viewership v
ON u.UserID = v.UserID;

---------------------------------------------------------------------
--- Show users who signed up but never watched
---(LEFT JOIN)

SELECT u.UserID, u.Name, u.Surname
FROM Sales_Analysis.Dataset.BrightTV_UserProfiles u
LEFT JOIN Sales_Analysis.Dataset.BrightTV_Viewership v
    ON u.UserID = v.UserID
WHERE v.UserID IS NULL;

----------------------------------------------------------------------
--️-How Viewership records with no matching profile
---(RIGHT JOIN)

SELECT v.UserID, v.Channel2, v.RecordDate2
FROM Sales_Analysis.Dataset.BrightTV_UserProfiles u
RIGHT JOIN Sales_Analysis.Dataset.BrightTV_Viewership v
ON u.UserID = v.UserID
WHERE u.UserID IS NULL;

----------------------------------------------------------------------
---Show the demographics of the users

SELECT DISTINCT Name, 
                Surname, 
                Gender, 
                Race, 
                Age, 
                Province
FROM Sales_Analysis.Dataset.BrightTV_UserProfiles;

-----------------------------------------------------------------------
---Show the TOP 3 channels thst are streamed the most

SELECT Channel2,
       Recorddate2,
       Duration2
FROM Sales_Analysis.Dataset.BrightTV_Viewership 
ORDER BY Channel2
LIMIT 3;

-----------------------------------------------------------------------
--FINAL BIG QUERY FOR ANALYSIS

SELECT 
    u.UserID,
    u.Name,
    u.Surname,
    u.Email,
    u.Gender,
    u.Age,
    u.Province,
    u.Social_Media_Handle,

    -- Age grouping for segmentation
    CASE  
        WHEN u.Age < 20 THEN 'Young'
        WHEN u.Age BETWEEN 20 AND 29 THEN 'Young Adults'
        WHEN u.Age BETWEEN 30 AND 39 THEN 'Adults'
        WHEN u.Age BETWEEN 40 AND 49 THEN 'Middle Age'
        ELSE 'Seniors'
    END AS AgeGroup,

    -------------------- VIEWERSHIP INFORMATION --------------------
    v.Channel2,

    -- Convert VARCHAR → TIMESTAMP using correct format
    TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI') AS RecordTimestamp,

    TO_DATE(TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI')) AS ViewDate,
    DATE_PART('hour', TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI')) AS HourOfDay,
    DAYNAME(TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI')) AS DayOfWeek,
    MONTHNAME(TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI')) AS MonthName,
    YEAR(TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI')) AS ViewYear,
    MONTH(TO_TIMESTAMP(v.RecordDate2, 'YYYY/MM/DD HH24:MI')) AS ViewMonth,

    -- Convert duration to seconds (CAST to TIME first!)
    DATEDIFF(SECOND, TIME '00:00:00', CAST(v.Duration2 AS TIME)) AS DurationSeconds,

    -- Revenue (R0.01 per second watched)
    DATEDIFF(SECOND, TIME '00:00:00', CAST(v.Duration2 AS TIME)) * 0.01 AS Revenue

FROM Sales_Analysis.Dataset.BrightTV_Viewership v
LEFT JOIN Sales_Analysis.Dataset.BrightTV_UserProfiles u
    ON v.UserID = u.UserID;