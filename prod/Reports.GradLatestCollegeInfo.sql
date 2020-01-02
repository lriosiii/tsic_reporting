SELECT  o.OfficeName
	  ,c.CountyName
      ,s.LastName
	  ,s.firstName
	  ,s.LastName + ', ' + s.FirstName AS FullName
	  ,s.StudentReferenceID
	  ,ss.StudentStatusName
	  ,ssc.SchoolName as HighSchool
	  ,s.HighSchoolDiplomaDate
	  ,s.GraduationYear
	  ,s.OfficeID
	  ,s.Affiliation
	  ,(
			SELECT TOP(1) ci.Clubs
			FROM Students.CollegeInformation ci
			Where ci.StudentID = s.StudentID
			AND ci.Clubs IS NOT NULL
			ORDER BY ci.LastEnrolledDate DESC
	  ) As LastCollegeClub
	  ,(
			SELECT TOP(1) dt.DegreeTypeName
			FROM Students.CollegeInformation ci
			INNER JOIN Lookups.DegreeTypes dt ON ci.CollegeDegreeTypeID = dt.DegreeTypeID
			Where ci.StudentID = s.StudentID
			AND ci.CollegeDegreeTypeID IS NOT NULL
			ORDER BY ci.ActualGraduationDate DESC
	  ) As LastDegreeTypeName
	  ,(
			SELECT TOP(1) ci.CollegeEmail
			FROM Students.CollegeInformation ci
			Where ci.StudentID = s.StudentID
			AND ci.CollegeEmail IS NOT NULL
			ORDER BY ci.LastEnrolledDate DESC
	  ) As LastCollegeEmail
	  ,(
			SELECT TOP(1) Col.CollegeName
			FROM Students.CollegeInformation ci
			INNER JOIN Lookups.Colleges col ON ci.CollegeID = col.CollegeID
			Where ci.StudentID = s.StudentID
			ORDER BY ci.LastEnrolledDate DESC
	  ) As LastCollegeName
	  ,(
			SELECT TOP(1) DATEPART(yyyy, ci.LastEnrolledDate) AS ColLastYearAttnd
			FROM Students.CollegeInformation ci
			Where ci.StudentID = s.StudentID
			AND ci.CollegeID IS NOT NULL
			ORDER BY ci.LastEnrolledDate DESC
	  ) As ColLastYearAttnd
	  ,(
			SELECT TOP(1)
			CASE DATEPART(qq, ci.LastEnrolledDate)
				WHEN 1 THEN 'Spring'
				WHEN 2 THEN 'Summer'
				WHEN 3 THEN 'Fall'
				WHEN 4 THEN 'Winter'
				ELSE 'N/A'
			END
			ColLastTermAttnd
			FROM Students.CollegeInformation ci
			Where ci.StudentID = s.StudentID
			AND ci.CollegeID IS NOT NULL
			ORDER BY ci.LastEnrolledDate DESC
	  ) As ColLastTermAttnd
	  ,(
			SELECT TOP(1) ci.EntryDate
			FROM Students.CollegeInformation ci
			Where ci.StudentID = s.StudentID
			AND ci.EntryDate IS NOT NULL
			ORDER BY ci.EntryDate
	  ) As FirstCollegeEntryDate
	  ,(
			SELECT TOP(1) ci.TranscriptReceivedDate
			FROM Students.CollegeInformation ci
			Where ci.StudentID = s.StudentID
			AND ci.TranscriptReceivedDate IS NOT NULL
			ORDER BY ci.LastEnrolledDate DESC
	  ) As LastTranscriptReceivedDate
	  ,(
			SELECT TOP(1) ci.ActualGraduationDate
			FROM Students.CollegeInformation ci
			Where ci.StudentID = s.StudentID
			AND ci.ActualGraduationDate IS NOT NULL
			ORDER BY ci.ActualGraduationDate DESC
	  ) As LastActualGraduationDate
	  ,(
			SELECT TOP(1)
			CASE
				WHEN ci.LastEnrolledDate >= '2018-01-01' THEN 1
				ELSE 0
			END
			Enrolled
			FROM Students.CollegeInformation ci
			Where ci.StudentID = s.StudentID
			AND ci.LastEnrolledDate IS NOT NULL
			ORDER BY ci.LastEnrolledDate DESC
	  ) As IsEnrolled
	  --,s.HighSchoolDiplomaDate
	  ,(
			SELECT TOP(1) cl.CollegeLevelName
			FROM Students.CollegeInformation ci
			INNER JOIN Lookups.CollegeLevels cl ON ci.CollegeLevelID = cl.CollegeLevelID
			Where ci.StudentID = s.StudentID
			AND ci.CollegeLevelID IS NOT NULL
			ORDER BY ci.LastEnrolledDate DESC
	  ) As LastCollegeLevelName
	  ,(
			SELECT TOP(1) cl.CollegeMajorName
			FROM Students.CollegeInformation ci
			INNER JOIN Lookups.CollegeMajors cl ON ci.CollegeLevelID = cl.CollegeMajorID
			Where ci.StudentID = s.StudentID
			AND ci.CollegeMajorID IS NOT NULL
			ORDER BY ci.LastEnrolledDate DESC
	  ) As LastCollegeMajorName
	  ,(
			SELECT TOP(1)
			Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(ci.Notes,',',''),'-',''),'+',''),'~',''),'`',''),'%',''),'!',''),'^',''),
			  CHAR(13),' '),CHAR(10),' ')
			  As Notes
			FROM Students.CollegeInformation ci
			Where ci.StudentID = s.StudentID
			AND ci.Notes IS NOT NULL
			ORDER BY ci.LastEnrolledDate DESC
	  ) As LastNotes
	  ,(
			SELECT TOP(1) ci.RemedialCollegeRequired
			FROM Students.CollegeInformation ci
			Where ci.StudentID = s.StudentID
			AND ci.RemedialCollegeRequired IS NOT NULL
			ORDER BY ci.LastEnrolledDate DESC
	  ) As LastRemedialCollegeRequired
	   ,(
			SELECT TOP (1) oss.MatriculationYear
			From Offices.Scholarships oss
			Where oss.StudentID = s.StudentID
			And oss.IsDeleted = 0
			ORDER BY HoursAvail DESC
	  ) As MatriculationYear
	 -- ,os.MatriculationYear
	  ,(
			SELECT TOP (1) oss.LastSchoolAttended
			From Offices.Scholarships oss
			Where oss.StudentID = s.StudentID
			And oss.IsDeleted = 0
			ORDER BY HoursAvail DESC
	  ) As LastSchoolAttended
	  --,os.LastSchoolAttended
	   ,(
			SELECT TOP (1) oss.LastTerm
			From Offices.Scholarships oss
			Where oss.StudentID = s.StudentID
			And oss.IsDeleted = 0
			ORDER BY HoursAvail DESC
	  ) As LastTerm
	 -- ,os.LastTerm
	  ,(
			SELECT TOP (1) oss.LastYearAttnd
			From Offices.Scholarships oss
			Where oss.StudentID = s.StudentID
			And oss.IsDeleted = 0
			ORDER BY HoursAvail DESC
	  ) As LastYearAttnd
	  --,os.LastYearAttnd
	   ,(
			SELECT TOP (1) oss.Donor
			From Offices.Scholarships oss
			Where oss.StudentID = s.StudentID
			And oss.IsDeleted = 0
			ORDER BY HoursAvail DESC
	  ) As Donor
	  --,os.Donor
	  ,(
			SELECT TOP (1) oss.ScholarshipOwner
			From Offices.Scholarships oss
			Where oss.StudentID = s.StudentID
			And oss.IsDeleted = 0
			ORDER BY HoursAvail DESC
	  ) As ScholarshipOwner

	  ,(
			SELECT TOP (1) oss.HoursAvail
			From Offices.Scholarships oss
			Where oss.StudentID = s.StudentID
			And oss.IsDeleted = 0
			ORDER BY HoursAvail DESC
	  ) As ScholarshipHoursAvail
	  --,os.ScholarshipOwner
	  ,s.EmailAddress
	  ,s.MobilePhoneNumber
	  ,s.WfiEligible
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
  --LEFT OUTER JOIN Students.CollegeInformation ci ON s.StudentID = ci.StudentID
  --LEFT OUTER JOIN Lookups.Colleges col ON ci.CollegeID = col.CollegeID
  --LEFT OUTER JOIN Lookups.CollegeLevels cl ON ci.CollegeLevelID = cl.CollegeLevelID
  --LEFT OUTER JOIN Lookups.CollegeMajors cm ON ci.CollegeMajorID = cm.CollegeMajorID
  --LEFT OUTER JOIN Lookups.DegreeTypes dt ON ci.CollegeDegreeTypeID = dt.DegreeTypeID
  LEFT OUTER JOIN Offices.Offices o On s.OfficeID = o.OfficeID
  LEFT OUTER JOIN Lookups.Counties c on s.CountyID = c.CountyID
  LEFT OUTER JOIN Lookups.StudentStatuses ss  ON s.StudentStatusID = ss.StudentStatusID
  left outer join schools.Schools ssc on s.SchoolID = ssc.SchoolID
 -- LEFT OUTER JOIN Offices.Scholarships os ON s.StudentID = os.StudentID

  Where s.StudentStatusID IN (11,12,13,14,15,25,28)
  AND s.IsDeleted = 0
  --And s.OfficeID = 13
  --And CollegeName = 'university of north florida'
  --order by s.LastName

  --Order By  ContractNumber  --OfficeName, LastName, FirstName
  --order by CollegeName