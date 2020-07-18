SELECT S.StudentReferenceID
	  , S.FirstName
	  , S.MiddleName
      , S.LastName
      , S.LastName+ ', '+ S.FirstName as StudentFullName
	  , S.Affiliation
	  , (Select Top 1 os.Donor
		 From Offices.Scholarships os
		 Where os.StudentID = S.StudentID
		 And os.IsDeleted = 0) As Donor
      , 'xxx-xx-' + RIGHT(CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedSSN)), 4) As SSN
      , CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate)) AS BirthDate
	  , S.ContractSignedDate
	  , S.DualEnrollmentCredits
	  , S.Gender
	  , S.Gifted
	  , S.Americorp
	  , S.WfiEligible
	  , R.RaceName
	  , S.CurrentGradeLevelID
	  , S.CommunityServiceHours
	  , SS.StudentStatusName
      , SC.SchoolName as SchoolName
	  , G.CumulativeUnweighted
	  , G.CumulativeWeighted
	  , G.SemesterWeighted
	  , G.SemesterUnweighted
      , G.SemesterEndDate
      , STT.SchoolTermTypeName as SchoolTerm
	  , a.FirstName + ' ' + a.LastName as AdvocateName      
	  , S.OfficeID 
	  , S.EntryGPA As EntryGPAInGeneralTile
	  , (SELECT TOP(1) Students.Applications.GPA
		 FROM Students.Applications
		 WHERE Students.Applications.StudentID = S.StudentID) As EntryGPAInApplication
	 ,o.OfficeName
	                       
FROM  Students.GPA G
	LEFT OUTER JOIN Students.Students S ON S.StudentID = G.StudentID
	LEFT OUTER JOIN Lookups.Races R On S.RaceID = R.RaceID
	LEFT OUTER JOIN Lookups.SchoolTermTypes STT ON G.SchoolTermTypeID = STT.SchoolTermTypeID
	LEFT OUTER  JOIN Schools.Schools SC ON S.SchoolID = SC.SchoolID
	LEFT OUTER  JOIN Lookups.StudentStatuses SS ON S.StudentStatusID = SS.StudentStatusID
	Left Outer JOIN Offices.Staff a on S.AdvocateID = a.StaffID
	LEFT JOIN offices.offices o ON s.officeid=o.officeid
WHERE G.IsDeleted = 0
And S.IsDeleted = 0

