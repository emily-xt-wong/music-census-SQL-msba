# Question 1: What is the geographic distribution of respondents (county, distance from downtown)?
SELECT county, 
	COUNT(*) AS num_respondents, 
    ROUND(AVG(DistanceDT), 2) AS avg_dist_dt
FROM respondent
GROUP BY county
ORDER BY avg_dist_dt;

# Question 2: What is the top 5 most common race demographic of respondents?
SELECT race, COUNT(*) AS num_respondents, COUNT(*)/total_responses AS percent_respondents
FROM (
	SELECT *, COUNT(*) OVER() AS total_responses
    FROM respondent
	WHERE race <> ''
) total
GROUP BY race
ORDER BY percent_respondents DESC LIMIT 5;

# Question 3: What is the distribution of respondents based on their role in the music scene (creative,
# presenter, industry)? 
SELECT job, COUNT(*) AS num_respondents, COUNT(*) / total_respondents as percent_respondents
FROM (
	SELECT * , 
    CASE
		WHEN r.respondent_id = c.respondent_id THEN 'creative'
		WHEN r.respondent_id = p.respondent_id THEN 'presenter'
		WHEN r.respondent_id = i.respondent_id THEN 'industry'
		ELSE 'no response'
	END AS job,
	(COUNT(*) OVER()) as total_respondents
    FROM respondent r
	# adding labels/identifiers based on respondent music role
	LEFT JOIN creative_income c USING(respondent_id)
	LEFT JOIN presenter p USING(respondent_id)
	LEFT JOIN industry i USING(respondent_id)
) all_responses
GROUP BY job
HAVING job <> 'no response' 
ORDER BY num_respondents DESC;

# Question 4: What is the average age of respondents based on their experience in the music industry?
SELECT DISTINCT 
	years_experience, 
    COUNT(*) OVER(PARTITION BY years_experience) as num_respondents,
    ROUND(AVG(age) OVER(PARTITION BY years_experience), 2) AS avg_age,
    AVG(age) OVER() AS total_avg_age
FROM respondent 
JOIN experience USING(respondent_id)
WHERE years_experience <> ''
ORDER BY FIELD(
	years_experience, 
    'No Response', 
    'Less than 3', 
    '3 to 5', 
    '6 to 10', 
    'More than 10'
);

# Question 5: What is the most popular response to continuing their career for 
# the next 3 years among each gender?
SELECT DISTINCT gender, 
	FIRST_VALUE(intent_continue_career_3yrs) OVER(
		PARTITION BY gender
		ORDER BY COUNT(intent_continue_career_3yrs) DESC
	) AS most_popular_response, 
	FIRST_VALUE(COUNT(*)) OVER(
		PARTITION BY gender
		ORDER BY COUNT(*) DESC
	) / total_responses AS percentage_respondents    
FROM (
	SELECT * , COUNT(*) OVER(PARTITION BY gender) as total_responses
    FROM respondent
	JOIN experience USING(respondent_id)
	WHERE gender <> ''
) gender_career
GROUP BY gender, intent_continue_career_3yrs;

# Question 6: What proportion of respondents need but lack a work or music space?
SELECT COUNT(*)/total_responses AS proportion_lacking
FROM (
	SELECT *, COUNT(*) OVER() AS total_responses
    FROM respondent
	JOIN experience USING(respondent_id)
	WHERE work_performance_space_status <> ''
) total
GROUP BY work_performance_space_status
HAVING work_performance_space_status = 'Need But Lack';

# Question 7: How much do music creatives in the Greater Austin area
# spend on average per year for their work?
SELECT DISTINCT
	AVG(annual_spend_recordings) OVER() AS avg_recordings, 
    AVG(annual_spend_promotion) OVER() AS avg_promotion, 
    AVG(annual_spend_social_media) OVER() AS avg_media,
    AVG(annual_spend_supplies) OVER() AS avg_supplies, 
    AVG(annual_spend_workspace)  OVER() AS avg_workspace, 
    AVG(annual_spend_gear_rentals)  OVER() AS avg_gear_rentals,
    AVG(annual_spend_merchandise) OVER() AS avg_merch, 
    AVG(annual_spend_legal)  OVER() AS avg_legal,
	AVG(annual_spend_recordings + 
	annual_spend_promotion + 
    annual_spend_social_media +
    annual_spend_supplies +
    annual_spend_workspace +
    annual_spend_gear_rentals +
    annual_spend_merchandise +
    annual_spend_legal 
) OVER() AS TotalAverageAnnualSpend 
FROM creative_spend;

# Question 8: Do creatives make the most profit from performances or recordings?
SELECT DISTINCT 
	FIRST_VALUE(income_performance_local) OVER(
		ORDER BY COUNT(income_performance_local) DESC
	) AS most_popular_response, 
	FIRST_VALUE(COUNT(*)) OVER(
		ORDER BY COUNT(*) DESC
	) / total_responses AS percentage_respondents,
    FIRST_VALUE(income_recordings) OVER(
		ORDER BY COUNT(income_recordings) DESC
	) AS most_popular_response_recordings, 
	FIRST_VALUE(COUNT(income_recordings)) OVER(
		ORDER BY COUNT(income_recordings) DESC
	) / total_responses AS percentage_respondents_recordings
FROM (
	SELECT * , COUNT(*) OVER() as total_responses
    FROM creative_income
	WHERE income_performance_local <> '' AND income_recordings <> ''
) income
GROUP BY income_performance_local, income_recordings;

# Question 9: What is the distribution of paid gigs per month among creatives?
SELECT paid_performances_per_month AS num_paid_gigs_monthly, 
	COUNT(paid_performances_per_month) AS num_gigs,
    COUNT(paid_performances_per_month) / total_creatives AS percent_creatives
FROM (
	SELECT * , (COUNT(paid_performances_per_month) OVER()) AS total_creatives
    FROM creative_income
    WHERE paid_performances_per_month <> ''
) total_creatives
GROUP BY paid_performances_per_month
ORDER BY FIELD(
	paid_performances_per_month, 
    '0', 
    '1 to 3', 
    '4 to 6', 
    '7 to 10', 
    '11 to 15',
    '16 or more'
);

# Question 10: Which aspect of their jobs do presenters face the most pressure?
SELECT DISTINCT AVG(talent_costs) OVER() AS talent_costs, 
AVG(crowd_work) OVER() AS crowd_work,
AVG(labor) OVER() AS labor,
AVG(property_tax) OVER() AS property_tax,
AVG(marketing) OVER() AS marketing,
AVG(permits) OVER() AS permits,
AVG(unpredicted_costs) OVER() AS unpredicted,
AVG(building_operations) OVER() AS operations 
FROM presenter_pressures;

# Question 11: What is the distribution of presenters' local performer ratios?
SELECT local_performers_ratio, 
	COUNT(local_performers_ratio) AS num_presenters,
    COUNT(local_performers_ratio) / total_presenters AS percent_presenters
FROM (
	SELECT * , (COUNT(local_performers_ratio) OVER()) AS total_presenters
    FROM presenter_talent
    WHERE local_performers_ratio <> ''
) total_presenters
GROUP BY local_performers_ratio
ORDER BY FIELD(
	local_performers_ratio,
    '0 percent',
    '1 to 24 percent',
    '25 to 49 percent',
    '50 to 74 percent',
    '75 to 100 percent',
    'I don\'t know'
);

# Question 12: Work related to music for industry?
SELECT work_related_to_music_percentage, 
	COUNT(work_related_to_music_percentage) AS num_industry,
    COUNT(work_related_to_music_percentage) / total_industry AS percent_industry
FROM (
	SELECT * , 
    (COUNT(work_related_to_music_percentage) OVER()) AS total_industry
    FROM industry
    JOIN experience USING(respondent_id)
    WHERE work_related_to_music_percentage <> ''
) total_industry
GROUP BY work_related_to_music_percentage
ORDER BY FIELD(
	work_related_to_music_percentage,
    '1 to 24 percent',
    '25 to 49 percent',
    '50 to 74 percent',
    '75 to 99 percent',
    '100 percent',
    'I don\'t know',
    'Not applicable'
);