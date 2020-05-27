SELECT S.FirstName
	  , S.MiddleName
      , S.LastName
      , S.LastName+ ', '+ S.FirstName as StudentFullName
      , CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedSSN)) AS SSN
      , CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate)) AS BirthDate
	  , S.StudentReferenceID
      , SS.StudentStatusName
	  , S.Affiliation
	  , (SELECT TOP 1 os.Donor
		 FROM Offices.Scholarships os
		 Where os.StudentID = S.StudentID
		 And os.IsDeleted = 0) As Donor
      , GL.GradeLevelName as CurrentGradeLevel
      , A.DaysExcused
      , A.DaysUnExcused
	  , A.SemesterEndDate
      , COALESCE(A.DaysExcused,0) + COALESCE(A.DaysUnExcused,0) as TotalDaysAbsent
      , STT.SchoolTermTypeName
	  , sch.SchoolName
      , S.OfficeID
FROM Students.Attendance A
	INNER JOIN Students.Students S ON A.StudentID = S.StudentID
	INNER JOIN Lookups.StudentStatuses SS ON S.StudentStatusID = SS.StudentStatusID
	INNER JOIN Schools.Schools sch ON s.SchoolID = sch.SchoolID
	LEFT OUTER JOIN Lookups.GradeLevels GL ON S.CurrentGradeLevelID = GL.GradeLevelID
	LEFT OUTER JOIN Lookups.SchoolTermTypes STT ON A.SchoolTermTypeID = STT.SchoolTermTypeID

WHERE a.IsDeleted = 0
