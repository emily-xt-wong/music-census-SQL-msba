CREATE DATABASE  IF NOT EXISTS `music_census`;
USE `music_census`;

DELETE FROM census_raw
WHERE `Residence Distance from Downtown in miles` = '' OR `Primary Music Ecosystem Sector` = 'None of these - Exit the Census';

ALTER TABLE census_raw drop COLUMN respondent_id;
-- SET SQL_SAFE_UPDATES = 0;
-- SET @row_number = 0;
-- UPDATE census_raw
-- SET respondent_id = (@row_number := @row_number + 1)
-- ORDER BY `County of Residence`;
-- ALTER TABLE census_raw ADD PRIMARY KEY (respondent_id);

#select respondent_id from census_raw;

DROP TABLE IF EXISTS `respondent`;
CREATE TABLE `respondent`
SELECT
  `County of Residence` AS county,
  `Residence Distance from Downtown in miles` AS DistanceDT,
  Race AS race,
  `Hispanic Latino Latina Latinx Origin` AS hispanic,
  `Age` AS age,
  `Gender` AS gender,
  `Sexual Orientation` AS sexual_orientation
FROM census_raw;

SELECT * FROM respondent;

ALTER TABLE respondent ADD PRIMARY KEY (respondent_id);

SELECT * FROM respondent;

DROP TABLE IF EXISTS `experience`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;

CREATE TABLE `experience`
(FOREIGN KEY (respondent_id) REFERENCES music_census(respondent_id))
SELECT 
  `Primary Music Ecosystem Sector` AS music_sector,
  `Years Experience` AS years_experience,
  `Music Education` AS music_education,
  `Suggested Music Training Topics` AS training_topics,
  `Suggested Level of Music Training` AS training_level,
  `Intent to Continue Music Career Next 3 Years` AS intent_continue_career_3yrs,
  Gender AS `gender`,
  `Community or Business Participation` AS community_business_participation,
  `Work Space Status including Venue Performance Space` AS work_performance_space_status
FROM census_raw;
/*!40101 SET character_set_client = @saved_cs_client */;

ALTER TABLE experience ADD (respondent_id int);
SET @row_number = 0;
UPDATE experience
SET respondent_id = (@row_number := @row_number + 1)
ORDER BY county;
ALTER TABLE experience ADD FOREIGN KEY (respondent_id) REFERENCES respondent(respondent_id);

select * from experience;

DROP TABLE IF EXISTS `creative_income`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;

CREATE TABLE `creative_income`
#create new table for income; one creative can have multiple sources of income
SELECT `C Income Live Performance Locally` AS income_performance_local,
  `C Income Live Performance Touring` AS income_performance_touring,
  `C Income Recordings` AS income_recordings,
  `C Income Songwriting` AS income_songwriting,
  `C Income Studio Work` AS income_studio_work,
  `C Income Merchandise` AS income_merchandise,
  `C Income Teaching` AS income_teaching,
  `C Paid Performances per Month` AS paid_performances_per_month,
  `C Percentage of Gigs Base Guarantee` AS paid_gigs_base_guarantee
FROM census_raw;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `creative_spend`;


CREATE TABLE `creative_spend`
SELECT
  `C Annual Spend New Recordings` AS annual_spend_recordings,
  `C Annual Spend Publicity Promotion` AS annual_spend_promotion,
  `C Annual Spend Social Media` AS annual_spend_social_media,
  `C Annual Spend Supplies` AS annual_spend_supplies,
  `C Annual Spending on Rehearsal or Work Space` AS annual_spend_workspace,
  `C Annual Spend Gear or Rentals` AS annual_spend_gear_rentals,
  `CREATIVES Annual Spending on Merchandise` AS annual_spend_merchandise,
  `CREATIVES Annual Spending on Accounting or Legal` AS annual_spend_legal
FROM census_raw;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `presenter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;

CREATE TABLE `presenter`
SELECT `PRESENTER Ownership Structure` AS ownership_structure,
  `PRESENTER Venue Type` AS venue_type,
  `PRESENTER Role of Live Music` AS role_live_music,
  `PRESENTER Venue Capacity` AS venue_capacity
FROM census_raw;
/*!40101 SET character_set_client = @saved_cs_client */;



DROP TABLE IF EXISTS `presenter_pressures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;

CREATE TABLE `presenter_pressures`
SELECT
  `PRESENTER Rank of Pressures TALENT COSTS` AS talent_costs,
  `P Rank Pressure CHANGING AUDIENCE BEHAVIORS` AS crowd_work,
  `P Rank of Pressures LABOR` AS labor,
  `P Ranking of Pressures PROPERTY TAX` AS property_tax,
  `P Ranking of Pressures MARKETING` AS marketing, 
  `P Ranking of Pressures ORDINANCES PERMITS` AS permits,
  `P Pressures UNPREDICTABLE COSTS` AS unpredicted_costs,
  `P Pressures BUILDING OPERATIONS` AS building_operations
FROM census_raw;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `presenter_talent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;

CREATE TABLE `presenter_talent`
SELECT
  `P Percent Guarantee as Business Expense` AS guarantee_as_business_expense,
  `P Percent Talent Deals Paid Door Proceeds` AS talent_paid_door_proceeds,
  `P Percent Talent Paid Percentage of Door Only` AS talent_paid_door_proceeds_only,
  `P Percent of Talent Deals Paid Fixed  Bar Sales` AS talent_paid_fixed_bar_sales,
  `P Percent of Talent Deals Paid by Tips Only` AS talent_paid_tips_only,
  `P Local Talent Bookings as Percent of Total Bookings` AS local_performers_ratio
FROM census_raw;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `industry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;

CREATE TABLE `industry`
SELECT `INDUSTRY Professional Experience in 13 subcategories` AS professional_experience,
  `Years Experience` AS years_experience,
  `INDUSTRY Percentage of Work Related to Music` AS work_related_to_music_percentage,
  `INDUSTRY Ranking of Client Geography AUSTIN AREA` AS austin_client_ranking,
  `INDUSTRY Ranking of Client Geography REST of USA` AS usa_client_ranking,
  `INDUSTRY Ranking of Client Geography INTERNATIONAL` AS international_client_ranking
FROM census_raw;
/*!40101 SET character_set_client = @saved_cs_client */;

