SELECT     o.OfficeID, o.OfficeName, sch.SchoolName, ss.StudentStatusName, s.StudentReferenceID AS StudentID, s.LastName + ', ' + s.FirstName AS StudentFullName, 
                      s.MiddleName, s.CurrentGradeLevelID AS CurrentGrade, s.CommunityServiceHours, s.DualEnrollmentCredits, s.APCredits, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedSSN)) AS SSN,
                      sf.DateCompleted AS FAFSACompletionDate, s.IsNationalMeritScholar, s.GraduationYear, s.IBEnrolled, s.WfiEligible,
                      s.HighSchoolDiplomaDate, s.FPPSeniorPacket, bf.BrightFutureName,
					  g.SemesterUnweighted, g.CumulativeUnweighted, g.SemesterEndDate,
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
					  ) As RemedialCollegeRequired,
					  (
						Select TOP(1) Colinfo.ContractNumber
						From Offices.Scholarships colinfo
						WHERE colinfo.StudentID = s.StudentID
						ORDER BY colinfo.PurchaseDate Desc
					  ) As ContractNumber

					  
					   
FROM         Students.Students AS s INNER JOIN
                      Lookups.StudentStatuses AS ss ON s.StudentStatusID = ss.StudentStatusID INNER JOIN
                      Schools.Schools AS sch ON sch.SchoolID = s.SchoolID INNER JOIN
                      Offices.Offices AS o ON o.OfficeID = s.OfficeID LEFT OUTER JOIN
					  Students.GPA g ON s.StudentID = g.StudentID And g.iscollege = 1 And g.isdeleted = 0 LEFT OUTER JOIN
                      --Students.CollegeApplications AS ca ON s.StudentID = ca.StudentID LEFT OUTER JOIN
                      --Students.CollegeInformation AS ci ON ci.StudentID = s.StudentID LEFT OUTER JOIN   --Took these out and did subqueries for college info becuase
                      --Lookups.Colleges AS SelCol ON SelCol.CollegeID = ci.CollegeID LEFT OUTER JOIN     --new college tab allows multiple entries on colleges in College Tracking Tile
                      --Lookups.Colleges AS cols ON ci.CollegeID = cols.CollegeID LEFT OUTER JOIN		  -- and this report should show only the last college entered.  JL 12/3/2014
                      Students.FAFSA AS sf ON s.StudentID = sf.StudentID LEFT OUTER JOIN
                      Lookups.BrightFutures AS bf ON s.BrightFutureID = bf.BrightFutureID 
--WHERE	  s.HighSchoolDiplomaDate Between '2013-12-01' AND '2014-06-30'
					  where s.StudentStatusID Between	11 and 15
					  And s.IsDeleted = 0
					  --AND s.GraduationYear = '2014'
					  --AND g.IsCollege = 1
					  --AND g.IsDeleted = 0
					  --And s.OfficeID = 39   -- Test Data
					 -- ORDER BY s.LastName
