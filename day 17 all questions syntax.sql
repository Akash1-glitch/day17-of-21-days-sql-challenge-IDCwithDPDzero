-- show each patient with their service's average satisfaction as an additional column.


SELECT
    p.*, -- Select all columns from the patients table (e.g., patient ID, name, etc.)
    service_avg.avg_satisfaction_score -- The calculated average satisfaction for the patient's service
FROM
    patients p
INNER JOIN
    ( -- This is the Derived Table (Subquery)
        SELECT
            service,
            AVG(patient_satisfaction) AS avg_satisfaction_score
        FROM
            services_weekly
        GROUP BY
            service
    ) AS service_avg
ON
    p.service = service_avg.service;
    
    
  -- 2.create a derived table of service statistics and query from it.
SELECT
    week_stats.week,
    week_stats.weekly_avg_satisfaction,
    overall.overall_hospital_avg_satisfaction
FROM
    ( -- Derived Table 1: weekly_stats
        SELECT
            week,
            AVG(patient_satisfaction) AS weekly_avg_satisfaction
        FROM
            services_weekly
        GROUP BY
            week
    ) AS week_stats
CROSS JOIN
    ( -- Derived Table 2: overall
        SELECT
            AVG(patient_satisfaction) AS overall_hospital_avg_satisfaction
        FROM
            services_weekly
    ) AS overall
ORDER BY
    week_stats.week;
    
    
 -- 3.Display staff with their service's total patient count as a calculated field.
SELECT
    s.staff_id,
    s.staff_name, -- Assuming a staff_name column exists
    s.service,
    service_counts.total_patient_count -- The calculated total patient count for the staff's service
FROM
    staff s
INNER JOIN
    ( -- This is the Derived Table (Subquery)
        SELECT
            service,
            COUNT(*) AS total_patient_count -- Calculates the total patient count per service
        FROM
            patients
        GROUP BY
            service
    ) AS service_counts
ON
    s.service = service_counts.service;
    
    
  ### Daily Challenge:

-- **Question:** Create a report showing each service with: service name, total patients admitted, the difference between their total admissions and the average admissions across all services, and a rank indicator ('Above Average', 'Average', 'Below Average'). Order by total patients admitted descending.  
SELECT
    service_stats.service,
    service_stats.total_admitted,
    service_stats.diff_from_avg,
    CASE
        WHEN service_stats.diff_from_avg > 0 THEN 'Above Average'
        WHEN service_stats.diff_from_avg < 0 THEN 'Below Average'
        ELSE 'Average'
    END AS performance_rank
FROM
    ( -- Derived Table: service_stats
        SELECT
            service,
            SUM(patients_admitted) AS total_admitted, -- 1. Calculate total admissions per service
            (
                SELECT AVG(total_admitted_agg)
                FROM (
                    SELECT SUM(patients_admitted) AS total_admitted_agg
                    FROM services_weekly
                    GROUP BY service
                ) AS sub_avg_calc
            ) AS avg_admitted_across_services, -- 2. Calculate the average of these totals
            SUM(patients_admitted) - (
                SELECT AVG(total_admitted_agg)
                FROM (
                    SELECT SUM(patients_admitted) AS total_admitted_agg
                    FROM services_weekly
                    GROUP BY service
                ) AS sub_diff_calc
            ) AS diff_from_avg -- 3. Calculate the difference (total - average)
        FROM
            services_weekly
        GROUP BY
            service
    ) AS service_stats
ORDER BY
    service_stats.total_admitted DESC;    