With Trn_CTE (tdate, Studentid, OfficeID, toffice, SemesterUnweightedGPA, GpaType, GpaDate) AS
(SELECT DISTINCT
	(	
		SELECT TOP (1) t.transferdate
		FROM students.schoolTransferHistory t
		--LEFT JOIN Students.Students s ON s.StudentID = t.StudentID 
		WHERE 1=1
			AND t.StudentID = s.StudentID
			AND s.IsDeleted = 0  AND t.IsDeleted = 0
		ORDER BY t.transferdate DESC
	)  AS tdate
	,s.StudentID
	,(
		SELECT TOP (1) t.OfficeID
		FROM Students.SchoolTransferHistory t 
		LEFT JOIN Offices.Offices o ON o.OfficeID = t.OfficeID
		--LEFT JOIN Students.Students s ON s.StudentID = t.StudentID 
		WHERE 1=1
			AND t.StudentID = s.StudentID
			AND s.IsDeleted = 0  AND t.IsDeleted = 0
	) AS officeid
	,(
		SELECT TOP (1) o.OfficeName
		FROM Students.SchoolTransferHistory t 
		LEFT JOIN Offices.Offices o ON o.OfficeID = t.OfficeID
		--LEFT JOIN Students.Students s ON s.StudentID = t.StudentID 
		WHERE 1=1
			AND t.StudentID = s.StudentID
			AND s.IsDeleted = 0  AND t.IsDeleted = 0
	) AS toffice
	,(	SELECT TOP (1) CASE WHEN g.SemesterUnweighted IS NULL THEN g.CumulativeUnweighted ELSE g.SemesterUnweighted END AS SemesterUnweighted
		FROM Students.GPA g
		WHERE 1=1
		AND g.StudentID = s.StudentID
		AND g.IsDeleted = 0
	) AS SemesterUnweightedGpa
	,(SELECT top (1)
			CASE 
			WHEN g.SemesterUnweighted is null THEN '1'
			WHEN  g.SemesterUnweighted is not null THEN '2'
			ELSE g.SemesterUnweighted
		END AS SemesterUnweighted
		FROM Students.GPA g
		WHERE 1=1
			AND g.StudentID = s.StudentID
			AND g.IsDeleted = 0
	) AS GPAType
	,(SELECT top (1) g.SemesterEndDate
		FROM Students.GPA g
		WHERE 1=1
			AND g.StudentID = s.StudentID
			AND g.IsDeleted = 0
	) AS GpaDate
	FROM [TSIC_Prod].[Students].[Students] s
	LEFT OUTER JOIN Offices.Offices o ON s.OfficeID = o.OfficeID
	INNER JOIN students.SchoolTransferHistory t ON s.StudentID = t.StudentID
  ),
  scholarshipdata AS 
	(  
	  SELECT stud.studentid, scholarshipowner, donor, hoursavail, plantype
	  FROM TSIC_Prod.offices.scholarships schol
	  JOIN TSIC_Prod.students.students stud ON schol.studentid=stud.studentid
	)

SELECT DISTINCT
	o.OfficeName AS CurrentOffice
	,LastName + ', ' + FirstName AS StudentName
	,CASE 
		WHEN s.CurrentGradeLevelID > 12 THEN ''
		ELSE s.CurrentGradeLevelID
		END CurrentGrade
	,tc.toffice AS OriginalOffice
	,tc.tdate AS TransferDate
	,ls.StudentStatusName
	,(SELECT top (1) l.ProbationLevelName +', '+ r.ProbationReasonName 
		FROM students.StatusHistory sh
		LEFT JOIN Lookups.ProbationLevels l ON sh.ProbationLevelID = l.ProbationLevelID
		LEFT JOIN lookups.ProbationReasons r ON sh.ProbationReasonID = r.ProbationReasonID
		WHERE 1=1
			AND sh.StudentID = s.StudentID 
			AND s.StudentStatusID in (1,3,4,5) 
			AND sh.IsDeleted = 0
		ORDER BY sh.StatusChangeDate DESC
		) AS LevelReason
	,s.ContractSignedDate
	,c.ContractTypeName AS ContractType
	,tc.SemesterUnweightedGPA AS LatestUnweightedGPA
	,	CASE
		WHEN tc.GpaType = 1.0 THEN 'Cumulative'
		WHEN tc.GpaType = 2.0 THEN 'Semester'
		ELSE''
		END AS GPAType
	,tc.GpaDate
	,s.Affiliation
	,s.OfficeID
	,s.CountyID
	,schol.scholarshipowner
	,schol.donor
	,schol.hoursavail
	,schol.plantype
  FROM [TSIC_Prod].[Students].[Students] s
  LEFT JOIN Offices.Offices o ON s.OfficeID = o.OfficeID
  LEFT JOIN lookups.ContractTypes c ON s.ContractTypeID =c.ContractTypeID
  LEFT JOIN scholarshipdata schol ON s.studentid=schol.studentid
  RIGHT JOIN Trn_CTE tc ON s.StudentID = tc.Studentid
  --INNER JOIN students.SchoolTransferHistory t ON s.StudentID = t.StudentID
  LEFT JOIN lookups.StudentStatuses ls ON s.StudentStatusID = ls.StudentStatusID
  WHERE 1=1
	AND s.IsDeleted = 0 
	AND s.OfficeID <> tc.OfficeID
