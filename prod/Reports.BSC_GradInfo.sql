SELECT    
	o.OfficeID, 
	o.OfficeName, 
	sch.SchoolName, 
	ss.StudentStatusName, 
	s.StudentReferenceID AS StudentID, 
	s.studentid AS StudID, 
	s.LastName + ', ' + s.FirstName AS StudentFullName, 
	s.MiddleName, 
	s.CurrentGradeLevelID AS CurrentGrade, 
	s.CommunityServiceHours, 
	s.DualEnrollmentCredits, 
	s.APCredits, 
	sf.DateCompleted AS FAFSACompletionDate, 
	s.IsNationalMeritScholar, 
	s.GraduationYear, 
	s.IBEnrolled, 
	s.WfiEligible,
	s.HighSchoolDiplomaDate, 
	s.FPPSeniorPacket, 
	bf.BrightFutureName,
	  (
		Select TOP(1) col.CollegeName 
		From Students.CollegeInformation colinfo
		LEFT OUTER JOIN Lookups.Colleges col ON colinfo.CollegeID = col.CollegeID
		WHERE colinfo.StudentID = s.StudentID
		ORDER BY colinfo.EntryDate Desc
	  ) As SelectedCollege,
	  (
		Select TOP(1) Colinfo.IsEnrolled
		From Students.CollegeInformation colinfo
		WHERE colinfo.StudentID = s.StudentID
		ORDER BY colinfo.EntryDate Desc
	  ) As IsEnrolled, 
	  (
		Select TOP(1) Colinfo.RemedialCollegeRequired
		From Students.CollegeInformation colinfo
		WHERE colinfo.StudentID = s.StudentID
		ORDER BY colinfo.EntryDate Desc
	  ) As RemedialCollegeRequired
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
					   
FROM Students.Students AS s 
INNER JOIN Lookups.StudentStatuses ss ON s.StudentStatusID = ss.StudentStatusID 
INNER JOIN Schools.Schools sch ON sch.SchoolID = s.SchoolID 
INNER JOIN  Offices.Offices o ON o.OfficeID = s.OfficeID 
LEFT JOIN  Students.FAFSA sf ON s.StudentID = sf.StudentID
--LEFT OUTER JOIN Students.CollegeApplications AS ca ON s.StudentID = ca.StudentID LEFT OUTER JOIN
--Students.CollegeInformation AS ci ON ci.StudentID = s.StudentID LEFT OUTER JOIN   --Took these out and did subqueries for college info becuase
--Lookups.Colleges AS SelCol ON SelCol.CollegeID = ci.CollegeID LEFT OUTER JOIN     --new college tab allows multiple entries on colleges in College Tracking Tile
--Lookups.Colleges AS cols ON ci.CollegeID = cols.CollegeID 		  -- and this report should show only the last college entered.  JL 12/3/2014
LEFT JOIN Lookups.BrightFutures bf ON s.BrightFutureID = bf.BrightFutureID
WHERE Year(s.HighSchoolDiplomaDate) = dbo.YearStartYYYY() and (s.StudentStatusID Between 11 and 15) 
