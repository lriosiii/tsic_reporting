SELECT S.StudentReferenceID
	, sts.StudentStatusName as CurrentStatus
	  , S.FirstName
	  , S.MiddleName
      , S.LastName
      , S.LastName+ ', '+ S.FirstName as StudentFullName
	  , S.ContractSignedDate
	  , ss.StudentStatusName as StatusChanges
	  ,sh.StatusChangeDate
	  , l.ProbationLevelName
	  ,pr.ProbationReasonName
	  , S.Gender
	  , S.CurrentGradeLevelID
	  ,sc.SchoolName
	  , a.FirstName + ' ' + a.LastName as AdvocateName  
	  , S.OfficeID 
	  ,s.Affiliation
	  ,o.officename
	  --,s.CountyID
	  
	                       
FROM  Students.StatusHistory sh
	left join lookups.StudentStatuses ss on sh.StudentStatusID = ss.StudentStatusID
	LEFT OUTER JOIN Students.Students s on s.StudentID = sh.StudentID
	--LEFT OUTER JOIN Lookups.Counties c On c.CountyID = s.CountyID
	LEFT OUTER JOIN Lookups.Races R On S.RaceID = R.RaceID
	LEFT OUTER JOIN Lookups.ProbationLevels l On sh.ProbationLevelID = l.ProbationLevelID
	LEFT OUTER JOIN Lookups.ProbationReasons pr On pr.ProbationReasonID = sh.ProbationReasonID
	LEFT OUTER  JOIN Lookups.StudentStatuses sts ON s.StudentStatusID = sts.StudentStatusID
	Left Outer JOIN Offices.Staff a on S.AdvocateID = a.StaffID
	left join schools.Schools sc on sc.SchoolID = s.SchoolID
	INNER JOIN offices.offices o ON o.officeid=s.officeid
--WHERE  G.SemesterEndDate > '2015-01-01'  -- These lines for tests and fixes.  JL
WHERE s.IsDeleted = 0
And sh.IsDeleted = 0
--and s.StudentStatusID in (1,3,4,5)
--And G.SchoolTermTypeID IN (17, 0) 
--AND
--S.OfficeID = 6
-- ORDER BY G.SemesterEndDate DESC
--order by s.LastName
--

