SELECT  o.OfficeName
	  ,c.CountyName
      ,s.LastName
	  ,s.firstName
	  ,s.LastName + ', ' + s.FirstName AS FullName
	  ,s.StudentReferenceID
	  ,ss.StudentStatusName
	  ,s.HighSchoolDiplomaDate
	  ,s.GraduationYear
	  ,s.OfficeID
	  ,s.Affiliation
	  ,ci.Clubs
	  ,dt.DegreeTypeName
	  ,ci.CollegeEmail
	  ,col.CollegeName
	  ,DATEPART(yyyy, ci.LastEnrolledDate) AS ColLastYearAttnd
	  ,CASE DATEPART(qq, ci.LastEnrolledDate)
			WHEN 1 THEN 'Spring'
			WHEN 2 THEN 'Summer'
			WHEN 3 THEN 'Fall'
			WHEN 4 THEN 'Winter'
			ELSE 'N/A'
		END
		 ColLastTermAttnd
	  ,ci.EntryDate
	  ,CASE DATEPART(qq, ci.EntryDate)
			WHEN 1 THEN 'Spring'
			WHEN 2 THEN 'Summer'
			WHEN 3 THEN 'Fall'
			WHEN 4 THEN 'Winter'
			ELSE 'N/A'
		END
		 EntryTerm
	  ,ci.ExpectedGraduationDate
	  ,ci.TranscriptReceivedDate
	  ,ci.ActualGraduationDate
	  ,ci.IsEnrolled
	  ,ci.GraduationDate
	  ,cl.CollegeLevelName
	  ,cm.CollegeMajorName
	  ,Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(ci.Notes,',',''),'-',''),'+',''),'~',''),'`',''),'%',''),'!',''),'^',''),
	  CHAR(13),' '),CHAR(10),' ')
	  As Notes
	  ,ci.RemedialCollegeRequired
	  ,os.MatriculationYear
	  ,os.LastSchoolAttended
	  ,os.LastTerm
	  ,os.LastYearAttnd
	  ,os.Donor
	  ,os.ScholarshipOwner
	  ,s.EmailAddress
	  ,s.MobilePhoneNumber
	  ,s.WfiEligible
	  ,s.BirthDate
	  ,ca.Address1
	  ,ca.Address2
	  ,ca.City
	  ,CA.StateID
	  ,CA.ZipCode
	  ,sch.SchoolName
	  ,(SELECT coll.collegename FROM lookups.colleges coll WHERE coll.collegeid=s.finalcollegeid) CollegePrepSelectedCollege
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
  LEFT OUTER JOIN Common.Addresses ca On s.AddressID = ca.addressID
  LEFT OUTER JOIN Students.CollegeInformation ci ON s.StudentID = ci.StudentID
  LEFT OUTER JOIN Lookups.Colleges col ON ci.CollegeID = col.CollegeID
  LEFT OUTER JOIN Lookups.CollegeLevels cl ON ci.CollegeLevelID = cl.CollegeLevelID
  LEFT OUTER JOIN Lookups.CollegeMajors cm ON ci.CollegeMajorID = cm.CollegeMajorID
  LEFT OUTER JOIN Lookups.DegreeTypes dt ON ci.CollegeDegreeTypeID = dt.DegreeTypeID
  LEFT OUTER JOIN Offices.Offices o On s.OfficeID = o.OfficeID
  LEFT OUTER JOIN Lookups.Counties c on s.CountyID = c.CountyID
  LEFT OUTER JOIN Lookups.StudentStatuses ss ON s.StudentStatusID = ss.StudentStatusID
  LEFT OUTER JOIN Offices.Scholarships os ON s.StudentID = os.StudentID
  LEFT OUTER JOIN Schools.Schools sch On s.SchoolID = sch.SchoolID

  Where s.StudentStatusID IN (11,12,13,14,15,25)
  AND s.IsDeleted = 0
  AND ci.IsDeleted = 0
  --And s.OfficeID = 13
  --And CollegeName = 'university of north florida'
  --order by s.LastName

  --Order By  ContractNumber  --OfficeName, LastName, FirstName
  --order by CollegeName