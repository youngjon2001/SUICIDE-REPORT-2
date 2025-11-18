USE [REAL2];

---------------------------------------------------------
-- 1. QUERY ALL TABLES
---------------------------------------------------------
SELECT * FROM Facilities;
SELECT * FROM [Human Resources];
SELECT * FROM [Crude suicide rates];
SELECT * FROM [Age-standardized suicide rates];
GO

---------------------------------------------------------
-- 2. CHECK FOR NULL VALUES
---------------------------------------------------------
-- Facilities Table
SELECT
  SUM(CASE WHEN Mental_hospitals IS NULL THEN 1 ELSE 0 END) AS missing_Mental_hospitals,
  SUM(CASE WHEN health_units IS NULL THEN 1 ELSE 0 END) AS missing_health,
  SUM(CASE WHEN outpatient_facilities IS NULL THEN 1 ELSE 0 END) AS missing_outpatient,
  SUM(CASE WHEN day_treatment IS NULL THEN 1 ELSE 0 END) AS missing_treatment,
  SUM(CASE WHEN residential_facilities IS NULL THEN 1 ELSE 0 END) AS missing_residential
FROM Facilities;
GO

-- Human Resources Table
SELECT
  SUM(CASE WHEN Psychiatrists IS NULL THEN 1 ELSE 0 END) AS missing_Psychiatrists,
  SUM(CASE WHEN Nurses IS NULL THEN 1 ELSE 0 END) AS missing_Nurses,
  SUM(CASE WHEN Social_workers IS NULL THEN 1 ELSE 0 END) AS missing_Social_workers,
  SUM(CASE WHEN Psychologists IS NULL THEN 1 ELSE 0 END) AS missing_Psychologists
FROM [Human Resources];
GO

---------------------------------------------------------
-- 3. CLEAN NULL VALUES
---------------------------------------------------------
-- Facilities Table
UPDATE Facilities SET Mental_hospitals       = COALESCE(Mental_hospitals, 0);
UPDATE Facilities SET health_units           = COALESCE(health_units, 0);
UPDATE Facilities SET outpatient_facilities  = COALESCE(outpatient_facilities, 0);
UPDATE Facilities SET day_treatment          = COALESCE(day_treatment, 0);
UPDATE Facilities SET residential_facilities = COALESCE(residential_facilities, 0);

-- Human Resources Table
UPDATE [Human Resources] SET Nurses         = COALESCE(Nurses, 0);
UPDATE [Human Resources] SET Social_workers = COALESCE(Social_workers , 0);
UPDATE [Human Resources] SET Psychologists  = COALESCE(Psychologists , 0);
UPDATE [Human Resources] SET Psychiatrists  = COALESCE(Psychiatrists , 0);
GO

---------------------------------------------------------
-- 4. YEAR WITH HIGHEST SUICIDE RATE
---------------------------------------------------------
SELECT 
    a.Country,
    x.YearName  AS Year_Highest_Rate,
    x.YearVal   AS Highest_Rate_Value
FROM [Age-standardized suicide rates] AS a
CROSS APPLY (
    SELECT TOP (1) YearName, YearVal
    FROM (VALUES 
            ('2000', a._2000),
            ('2010', a._2010),
            ('2015', a._2015),
            ('2016', a._2016)
         ) AS v(YearName, YearVal)
    ORDER BY YearVal DESC
) AS x
WHERE a.Sex = 'Both sexes'
ORDER BY a.Country;
GO

---------------------------------------------------------
-- 5. SEX WITH HIGHEST SUICIDE RATE (MALE VS FEMALE)
---------------------------------------------------------
SELECT
    Country,
    MAX(CASE WHEN Sex = 'Male' THEN [_2016] END) AS Male_2016,
    MAX(CASE WHEN Sex = 'Female' THEN [_2016] END) AS Female_2016
FROM [Age-standardized suicide rates]
GROUP BY Country
ORDER BY Country ASC;
GO

---------------------------------------------------------
-- 6. TOP 10 AGE-GROUP SUICIDE RATES ACROSS AFRICA
---------------------------------------------------------
SELECT TOP 10 *
FROM (
    SELECT Country, '10–19' AS Age_Group, _10to19 AS Rate FROM [Crude suicide rates] WHERE Sex = 'Both sexes'
    UNION ALL SELECT Country, '20–29', _20to29 FROM [Crude suicide rates] WHERE Sex = 'Both sexes'
    UNION ALL SELECT Country, '30–39', _30to39 FROM [Crude suicide rates] WHERE Sex = 'Both sexes'
    UNION ALL SELECT Country, '40–49', _40to49 FROM [Crude suicide rates] WHERE Sex = 'Both sexes'
    UNION ALL SELECT Country, '50–59', _50to59 FROM [Crude suicide rates] WHERE Sex = 'Both sexes'
    UNION ALL SELECT Country, '60–69', _60to69 FROM [Crude suicide rates] WHERE Sex = 'Both sexes'
    UNION ALL SELECT Country, '70–79', _70to79 FROM [Crude suicide rates] WHERE Sex = 'Both sexes'
    UNION ALL SELECT Country, '80+', _80_above FROM [Crude suicide rates] WHERE Sex = 'Both sexes'
) AS Combined
ORDER BY Rate DESC;
GO

---------------------------------------------------------
-- 7. TOP 10 COUNTRIES WITH MOST MENTAL HOSPITALS
---------------------------------------------------------
SELECT TOP 10 
    Country, Mental_hospitals
FROM Facilities
ORDER BY Mental_hospitals DESC;
GO

---------------------------------------------------------
-- 8. COUNTRY WITH BEST STAFF DENSITY
---------------------------------------------------------
SELECT 
    Country,
    MAX(Psychiatrists)  AS Highest_Psychiatrist_Count,
    MAX(Nurses)         AS Highest_Nurses_Count,
    MAX(Social_workers) AS Highest_Social_Workers_Count,
    MAX(Psychologists)  AS Highest_Psychologists_Count
FROM [Human Resources]
GROUP BY Country
ORDER BY 
    Highest_Psychiatrist_Count DESC,
    Highest_Nurses_Count DESC,
    Highest_Social_Workers_Count DESC,
    Highest_Psychologists_Count DESC;
GO

---------------------------------------------------------
-- 9. TRENDS OF SUICIDE RATE (2000–2016)
---------------------------------------------------------
SELECT 
    Country,
    [_2000] AS Rate_2000,
    [_2010] AS Rate_2010,
    [_2015] AS Rate_2015,
    [_2016] AS Rate_2016
FROM [Age-standardized suicide rates]
WHERE Sex = 'Both sexes'
ORDER BY Country;
GO

---------------------------------------------------------
-- 10. HIGHEST-RISK AGE GROUP FOR EVERY COUNTRY
---------------------------------------------------------
SELECT 
    a.Country,
    x.Age_Group AS Highest_Risk_Age_Group,
    x.Value     AS Highest_Rate
FROM [Crude suicide rates] AS a
CROSS APPLY (
    SELECT TOP (1) Age_Group, Value
    FROM (VALUES
        ('10–19',  a._10to19),
        ('20–29',  a._20to29),
        ('30–39',  a._30to39),
        ('40–49',  a._40to49),
        ('50–59',  a._50to59),
        ('60–69',  a._60to69),
        ('70–79',  a._70to79),
        ('80+',    a._80_above)
    ) AS v(Age_Group, Value)
    ORDER BY Value DESC
) AS x
WHERE a.Sex = 'Both sexes'
ORDER BY a.Country;
GO

---------------------------------------------------------
-- 11. TOP 10 COUNTRIES WITH HIGHEST SUICIDE RATE (2016)
---------------------------------------------------------
SELECT TOP 10
    Country,
    [_2016] AS Suicide_Rate_2016
FROM [Age-standardized suicide rates]
WHERE Sex = 'Both sexes'
ORDER BY Suicide_Rate_2016 DESC;
GO
