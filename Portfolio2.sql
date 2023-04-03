SELECT *
FROM [dbo].[Netflix_Data]

-- Select the data we are going to be using 

SELECT DISTINCT F14, COUNT(F14), F15, COUNT(F15), F16, COUNT(F16), F17, COUNT(F17)
FROM [dbo].[Netflix_Data]
GROUP BY F14, F15, F16, F17                -- columns filled with null values

ALTER TABLE [dbo].[Netflix_Data]
DROP COLUMN F14, F15, F16, F17, F18, F19, F20
----------------------------------------------------------------------------------------------------------------------------------------

-- Are there more TV SHOW or MOVIES ? 

SELECT [Content Type], count([Content Type]) coun
FROM [dbo].[Netflix_Data]
GROUP BY [Content Type]		                      -- 3867 movies for 2100 tv show


----------------------------------------------------------------------------------------------------------------------------------------

-- Which of TV SHOW and MOVIES has the best score ? 

SELECT q.[Content Type], ROUND(AVG(CAST(q.Score as FLOAT)), 2) avg_score             -- change from nvarchar to float
FROM 
	(SELECT [Content Type], SUBSTRING([Imdb Score], 1, CHARINDEX('/', [Imdb Score]) - 1) Score      -- remove the '/10'
	FROM [dbo].[Netflix_Data]
	WHERE [Imdb Score] IS NOT NULL ) q
GROUP BY q.[Content Type]
ORDER BY 2 DESC                                     -- We see that the average rating of TV shows (7.13) slightly exceed Movies (6.24).

----------------------------------------------------------------------------------------------------------------------------------------

-- Which 5 country produced the most movies (not tv shows) between 2018 & 2020.

WITH date_count as 
	(SELECT DISTINCT [Release Date]
	FROM [dbo].[Netflix_Data])

SELECT COUNT([Release Date])  num_of_date
FROM date_count                                   -- we have 65 differents dates. 



SELECT TOP 5 [Production Country], COUNT([Content Type]) total_movies
FROM [dbo].[Netflix_Data]
WHERE [Release Date] BETWEEN 2018 AND 2020 AND [Content Type] IN ('Movie') AND [Production Country] IS NOT NULL
GROUP BY [Production Country]
ORDER BY 2 DESC                                            -- We see that the United States is far ahead of the other countries in the ranking.


----------------------------------------------------------------------------------------------------------------------------------------

-- Who are the 3 producers who make the most romantics films / TV shows ?

SELECT TOP 3 q.Director, COUNT(q.Genres) total_romantic_movies
FROM 
	(SELECT Director, Genres
	FROM [dbo].[Netflix_Data]
	WHERE Genres LIKE ('%Romantic_Movies%') AND Director IS NOT NULL) q
GROUP BY q.Director
ORDER BY 2 DESC                   -- Cathy Garcia-Molina, Justin G. Dyck & Antoinette Jadaone are the ones who have produced the most romantic films


----------------------------------------------------------------------------------------------------------------------------------------

-- Clearly display the release dates to be able to use them more easily (for the next question).

SELECT [Date Added], 
	SUBSTRING([Date Added], CHARINDEX(' ', [Date Added]),  3) Day_,
	SUBSTRING([Date Added], 1, CHARINDEX(' ', [Date Added])) Month_,
	SUBSTRING([Date Added], CHARINDEX(',', [Date Added]) + 1, LEN([Date Added])) Year_
FROM [dbo].[Netflix_Data]
WHERE [Date Added] IS NOT NULL


ALTER TABLE [dbo].[Netflix_Data]
ADD Day_Added NVARCHAR(255)

ALTER TABLE [dbo].[Netflix_Data]
ADD Month_Added NVARCHAR(255)

ALTER TABLE [dbo].[Netflix_Data]
ADD Year_Added INT

UPDATE [dbo].[Netflix_Data]
SET Day_Added = SUBSTRING([Date Added], CHARINDEX(' ', [Date Added]),  3)

UPDATE [dbo].[Netflix_Data]
SET Month_Added = SUBSTRING([Date Added], 1, CHARINDEX(' ', [Date Added]))

UPDATE [dbo].[Netflix_Data]
SET Year_Added = SUBSTRING([Date Added], CHARINDEX(',', [Date Added]) + 1, LEN([Date Added]))

----------------------------------------------------------------------------------------------------------------------------------------

-- which genres are rated the best ? 

WITH genre_score as 
	(SELECT Genres, [Imdb Score], SUBSTRING([Imdb Score], 1, CHARINDEX('/', [Imdb Score]) - 1) score
	FROM [dbo].[Netflix_Data]
	WHERE [Imdb Score] IS NOT NULL)

SELECT *
FROM 
	(SELECT *, Max(score) over() max_score 
	FROM genre_score ) q
WHERE q.score = q.max_score                        -- Crime TV Shows, TV Dramas, TV Thrillers

----------------------------------------------------------------------------------------------------------------------------------------

-- What are the months of releases where the TV SHOWS were the longest and what were the country of production and the directors? 

SELECT  z.Director, z.[Production Country] ,z.Month_Added
FROM
	(SELECT *, MAX(q.total_seasons) over() max_season          -- the longest TV Show is 9 seasons
	FROM 
		(SELECT Director, [Production Country], Duration, SUBSTRING(Duration, 1, CHARINDEX(' ', Duration)) total_seasons, Month_Added
		FROM [dbo].[Netflix_Data]
		WHERE Director IS NOT NULL AND Month_Added IS NOT NULL AND [Content Type] IN ('TV Show')) q ) z

WHERE z.total_seasons = z.max_season           
												 -- Directors -> Philippa Lowthorpe, Hayato Date
												 -- Countries -> United Kingdom, Japan
												 -- Month -> September 