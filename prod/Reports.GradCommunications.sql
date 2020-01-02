SELECT  o.OfficeName
	  ,c.CountyName
      ,s.LastName
	  ,s.firstName
	  ,s.MiddleName
	  ,s.Gender
	  ,ss.StudentStatusName
	  ,cc.NoteDate
	  ,cc.Note
	  ,(
			Select TOP(1) CollegeName
			From
			Students.CollegeInformation ci1
			INNER JOIN Lookups.Colleges col1 ON ci1.CollegeID = col1.CollegeID
			INNER JOIN Students.Students s1 ON ci1.StudentID = s1.StudentID
			Where s1.StudentID = s.StudentID
			ORDER By ci1.EntryDate DESC
	   ) As LastCollegeName
	    ,(
			Select TOP(1) TranscriptReceivedDate
			From
			Students.CollegeInformation ci1
			INNER JOIN Lookups.Colleges col1 ON ci1.CollegeID = col1.CollegeID
			INNER JOIN Students.Students s1 ON ci1.StudentID = s1.StudentID
			Where s1.StudentID = s.StudentID
			ORDER By ci1.TranscriptReceivedDate DESC
	   ) As LastTranscriptReceivedDate
	  ,gcc.CommunicationMethodName
	  ,s.HighSchoolDiplomaDate
	  ,s.GraduationYear
	  ,s.SSN
	  ,s.BirthDate
	  ,s.HomePhoneNumber
	  ,s.WorkPhoneNumber
	  ,s.MobilePhoneNumber
	  ,s.EmailAddress
	  ,s.OfficeID
	  ,(									---- Added College GPA data   6/9/2015   JL
			SELECT TOP (1) gpa.SemesterUnweighted
			From Students.GPA gpa
			Where gpa.StudentID = s.StudentID
			And gpa.IsCollege = 1
			And gpa.IsDeleted = 0
			ORDER BY SemesterEndDate DESC
	  ) As LastCollegeSemesterUnweightedGPA
	  ,(
			SELECT TOP (1) gpa.CumulativeUnweighted
			From Students.GPA gpa
			Where gpa.StudentID = s.StudentID
			And gpa.IsCollege = 1
			And gpa.IsDeleted = 0
			ORDER BY SemesterEndDate DESC
	  ) As LastCollegeCumulativeUnweightedGPA
	  ,(
			SELECT TOP (1) gpa.SemesterEndDate
			From Students.GPA gpa
			Where gpa.StudentID = s.StudentID
			And gpa.IsCollege = 1
			And gpa.IsDeleted = 0
			ORDER BY SemesterEndDate DESC
	  ) As LastCollegeSemesterEndDateGPA



  FROM [Students].[Students] s
  LEFT OUTER JOIN Students.CollegeCommunications cc On s.StudentID = cc.StudentID
  INNER JOIN Lookups.GraduateCommunicationMethods gcc on cc.CollegeCommunicationTypeID = gcc.CommunicationMethodId
  LEFT OUTER JOIN Offices.Offices o On s.OfficeID = o.OfficeID
  LEFT OUTER JOIN Lookups.Counties c on s.CountyID = c.CountyID
  LEFT OUTER JOIN Lookups.StudentStatuses ss ON s.StudentStatusID = ss.StudentStatusID


  Where s.StudentStatusID IN (11,12,13,14,15,25)
  AND s.IsDeleted = 0

  --Order By  ContractNumber  --OfficeName, LastName, FirstName