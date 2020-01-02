SELECT
	  s.[StudentID] AS 'customer_id'
      ,REPLACE(REPLACE(s.LastName,'"', ''), ',', '') AS 'last_name'
	  ,REPLACE(REPLACE(s.FirstName, '"', ''), ',', '') AS 'first_name'
	  ,case
		when s.MobilePhoneNumber IS NULL AND s.HomePhoneNumber IS NULL THEN '1555555' + RIGHT(s.studentid, 4)
		when s.MobilePhoneNumber = '' AND s.HomePhoneNumber = '' then '1555555' + RIGHT(s.studentid, 4)
		when s.MobilePhoneNumber is null then dbo.SignalVinePhoneFormat(s.HomePhoneNumber)
		when s.MobilePhoneNumber = '' then dbo.SignalVinePhoneFormat(s.HomePhoneNumber)
		else dbo.SignalVinePhoneFormat(s.MobilePhoneNumber)
		end as phone
	  ,'G'+CONVERT(varchar(12), DATEPART(yy, GraduationYear)) as group_list
	  ,'US/Eastern' as 'timezone'
	  ,sc.SchoolName AS 'high_school'
	  ,ss.StudentStatusName AS student_status
	  ,GraduationYear AS graduation_year
	  ,ISNULL(os.FirstName +' '+os.LastName, '') as college_success_coach
	  ,s.EmailAddress AS email_address
	  ,c.CountyName AS county_name
	  ,REPLACE(o.OfficeName, ',', ';') AS office_name
	  ,ISNULL(
		lastCollege.Collegename,
		'') As last_college
	  ,ISNULL(
	  (SELECT TOP(1) Col.CollegeName
		FROM Students.CollegeApplications ca
		INNER JOIN Lookups.Colleges col ON ca.CollegeID = col.CollegeID
		Where ca.StudentID = s.StudentID
		AND ca.DateAccepted IS NOT NULL
		ORDER BY ca.StudentRankingOrder, ca.DateAccepted ASC
	  ), '') As selected_college

  FROM [TSIC_Prod].[Students].[Students] s
  left join lookups.Counties c on c.CountyID = s.CountyID
  LEFT JOIN (
				SELECT
					row_number() over (partition by ci.studentid order by ci.lastenrolleddate DESC) as RowNbr ,
					ci.studentid,
					Col.CollegeName,
					ci.lastenrolleddate
				FROM students.collegeinformation ci
				INNER JOIN Lookups.Colleges col ON ci.CollegeID = col.CollegeID
				WHERE ci.entrydate IS NOT NULL
			) lastCollege ON s.StudentID=lastCollege.StudentID AND lastCollege.RowNbr = 1
  left join lookups.StudentStatuses ss on s.StudentStatusID = ss.StudentStatusID
  left join schools.Schools sc on sc.SchoolID = s.SchoolID
  left join offices.Staff os on os.StaffID = s.AdvocateID
  left join offices.Offices o on o.OfficeID = s.OfficeID

  where s.IsDeleted = 0
  and s.StudentStatusID in (1,3,4,5,11,12,13,14,15,28)
	--TODO dyanmic gradyear 'last 5 years'
  and s.graduationyear BETWEEN 2015 AND 2019
  AND (
		lastCollege.CollegeName IN
			('Broward College',
			 'Chipola College',
			 'College of Central Florida',
			 'Daytona State College',
			 'Eastern Florida State College',
			 'Florida Gateway College',
			 'Florida Keys Community College',
			 'Florida SouthWestern State College',
			 'Florida State College at Jacksonville',
			 'Gulf Coast State College',
			 'Hillsborough Community College',
			 'Indian River State College',
			 'Lake-Sumter State College',
			 'Miami Dade College',
			 'North Florida Community College',
			 'Northwest Florida State College',
			 'Palm Beach State College',
			 'Pasco-Hernando State College',
			 'Pensacola State College',
			 'Polk State College',
			 'Santa Fe College',
			 'Seminole State College',
			 'South Florida State College',
			 'St. Petersburg College',
			 'St. Johns River State College',
			 'State College of Florida',
			 'Tallahassee Community College',
			 'Valencia College',
			 'Florida A&M University',
			 'Florida Atlantic University',
			 'Florida Gulf Coast University',
			 'Florida International University',
			 'Florida Polytechnic University',
			 'Florida State University',
			 'New College of Florida',
			 'University of Central Florida',
			 'University of Florida',
			 'University of North Florida',
			 'University of South Florida',
			 'University of West Florida') OR s.graduationyear = 2019)
