SELECT S.FirstName
	  , S.MiddleName
      , S.LastName
      , S.LastName+ ', '+ S.FirstName as StudentFullName
	  , S.StudentReferenceID
      , CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedSSN)) AS SSN
      , CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate)) AS BirthDate
      , GL.GradeLevelName as CurrentGradeLevel
      , SC.SchoolName as SchoolName
      , G.SemesterEndDate
      , LG.LetterGradeName as LetterGrade
      , LG.[Weight] as GradeWeight
      , STT.SchoolTermTypeName as SchoolTerm      
      , C.CourseCode
      , C.CourseName
      , SB.SubjectName
	  , S.OfficeID                      
FROM  Students.Students S 
	INNER JOIN Students.Grades G ON S.StudentID = G.StudentID
		INNER JOIN Lookups.LetterGrades LG ON G.LetterGradeID = LG.LetterGradeID
		INNER JOIN Lookups.SchoolTermTypes STT ON G.SchoolTermTypeID = STT.SchoolTermTypeID
		INNER JOIN Lookups.Courses C ON G.CourseID = C.CourseID
			LEFT OUTER JOIN Lookups.Subjects SB ON C.SubjectID = SB.SubjectID	
	LEFT OUTER JOIN Schools.Schools SC ON S.SchoolID = SC.SchoolID
	LEFT OUTER JOIN Lookups.GradeLevels GL ON S.CurrentGradeLevelID = GL.GradeLevelID
