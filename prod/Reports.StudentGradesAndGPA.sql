SELECT S.FirstName
	  , S.MiddleName
      , S.LastName
      , S.LastName+ ', '+ S.FirstName as StudentFullName
	  , S.StudentReferenceID As StudentID
	  , SST.StudentStatusName
      , CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedSSN)) AS SSN
      , CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate)) AS BirthDate
	  , S.Gender
	  , R.RaceName
	  , S.IsHispanic
      , GL.GradeLevelName as CurrentGradeLevel
      , SC.SchoolName as SchoolName
	  , (
			Select OS.LastName + ', ' + OS.FirstName 
			From Offices.Staff OS
			Where S.AdvocateID = OS.StaffID
	    ) As AdvocateName
      , G.SemesterEndDate
      , LG.LetterGradeName as LetterGrade
      , LG.[Weight] as GradeWeight
      , STT.SchoolTermTypeName as SchoolTerm      
      , C.CourseCode
      , C.CourseName
      , SB.SubjectName
	  , (
			Select TOP(1) GPA.SemesterUnweighted
			From Students.GPA GPA 
			Where S.StudentID = GPA.StudentID
			And GPA.SchoolTermTypeID = G.SchoolTermTypeID
			And GPA.SemesterEndDate BETWEEN DateAdd(day,-15,G.SemesterEndDate) And DATEADD(day,15,G.SemesterEndDate)
			Order By GPA.SemesterEndDate DESC
	    ) As GPA_SemesterUnweightedThisTerm
	   , (
			Select TOP(1) GPA.SemesterWeighted
			From Students.GPA GPA 
			Where S.StudentID = GPA.StudentID
			And GPA.SchoolTermTypeID = G.SchoolTermTypeID
			And GPA.SemesterEndDate BETWEEN DateAdd(day,-15,G.SemesterEndDate) And DATEADD(day,15,G.SemesterEndDate)
			Order By GPA.SemesterEndDate DESC
	    ) As GPA_SemesterWeightedThisTerm
	   , (
			Select TOP(1) GPA.CumulativeUnweighted
			From Students.GPA GPA 
			Where S.StudentID = GPA.StudentID
			And GPA.SchoolTermTypeID = G.SchoolTermTypeID
			And GPA.SemesterEndDate BETWEEN DateAdd(day,-15,G.SemesterEndDate) And DATEADD(day,15,G.SemesterEndDate)
			Order By GPA.SemesterEndDate DESC
	    ) As GPA_CumulativeUnweightedThisTerm
	   , (
			Select TOP(1) GPA.CumulativeWeighted
			From Students.GPA GPA 
			Where S.StudentID = GPA.StudentID
			And GPA.SchoolTermTypeID = G.SchoolTermTypeID
			And GPA.SemesterEndDate BETWEEN DateAdd(day,-15,G.SemesterEndDate) And DATEADD(day,15,G.SemesterEndDate)
			Order By GPA.SemesterEndDate DESC
	    ) As GPA_CumulativeweightedThisTerm
	  , CA.Address1
	  , CA.Address2
	  , CA.City
	  , CA.StateID
	  , CA.ZipCode
	  , S.HomePhoneNumber
	  , S.MobilePhoneNumber
	  , S.OfficeID                      
FROM  Students.Students S 
	INNER JOIN Students.Grades G ON S.StudentID = G.StudentID
		INNER JOIN Lookups.LetterGrades LG ON G.LetterGradeID = LG.LetterGradeID
		INNER JOIN Lookups.SchoolTermTypes STT ON G.SchoolTermTypeID = STT.SchoolTermTypeID
		INNER JOIN Lookups.StudentStatuses SST ON S.StudentStatusID = SST.StudentStatusID
		INNER JOIN Lookups.Courses C ON G.CourseID = C.CourseID
		INNER JOIN Lookups.Races R On S.RaceID = R.RaceID
		LEFT OUTER JOIN Lookups.Subjects SB ON C.SubjectID = SB.SubjectID	
	LEFT OUTER JOIN Schools.Schools SC ON S.SchoolID = SC.SchoolID
	LEFT OUTER JOIN Lookups.GradeLevels GL ON S.CurrentGradeLevelID = GL.GradeLevelID
	LEFT OUTER JOIN Common.Addresses CA ON S.AddressID = CA.AddressID
