SELECT  o.OfficeName
	  ,c.CountyName
      ,[ScholarshipID]
      ,s.LastName
	  ,s.firstName
	  ,s.EmailAddress
	  ,ss.StudentStatusName
	  --,s.CurrentGradeLevelID
	  ,ssc.ContractNumber
      ,[ScholarshipStatusName]
	  ,ssc.CurrentDormPlanValue
	  ,ssc.CurrentTDFPlanValue
	  ,ssc.Donor
	  ,ssc.DormAccountNumber
	  ,ssc.DormContractPrice
	  ,ssc.DormSemestersAvailable
	  ,ssc.HoursAvail
	  ,ssc.LastSchoolAttended
	  ,ssc.LastTerm
	  ,ssc.LastYearAttnd
	  ,ssc.LocalContractNumber
	  ,ssc.LocalHours
	  ,ssc.LocalPrice
	  ,ssc.LocalValue
	  ,ssc.MatriculationYear
	  ,ssc.OriginalPey
	  ,ssc.PlanType
	  ,ssc.Price
	  ,ssc.PurchaseDate
	  ,ssc.ScholarshipTypeID
	  ,ssc.TDFAccountNumber
	  ,ssc.TDFContractPrice
	  ,ssc.TDFHoursAvailable
	  ,ssc.Value
	  ,s.HighSchoolDiplomaDate
	  ,s.OfficeID
	  ,s.Affiliation
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
  LEFT OUTER JOIN [Offices].[Scholarships] ssc ON s.StudentID = ssc.StudentID
  LEFT OUTER JOIN Offices.Offices o On s.OfficeID = o.OfficeID
  LEFT OUTER JOIN Lookups.Counties c on s.CountyID = c.CountyID
  LEFT OUTER JOIN Lookups.StudentStatuses ss ON s.StudentStatusID = ss.StudentStatusID
  LEFT OUTER JOIN lookups.ScholarshipStatus scs ON ssc.ScholarshipStatusID = scs.ScholarshipStatusID

  Where s.StudentStatusID IN (11,12,13,14,15,25)
  AND s.IsDeleted = 0

  --Order By  ContractNumber  --OfficeName, LastName, FirstName