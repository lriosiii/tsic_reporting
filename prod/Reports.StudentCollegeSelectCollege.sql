SELECT     o.OfficeID, counties.countyname ,o.OfficeName, sch.SchoolName, ss.StudentStatusName, s.StudentReferenceID AS StudentID, s.LastName + ', ' + s.FirstName AS StudentFullName,
                      s.MiddleName, s.GraduationYear AS HSGraduationYear, s.CurrentGradeLevelID AS CurrentGrade, s.CommunityServiceHours, s.DualEnrollmentCredits, s.APCredits, s.EmailAddress,
                      sf.DateCompleted AS FAFSACompletionDate,
					  --cols.CollegeName,
					  SelCol.CollegeName AS SelectedCollege,
					  --ca.StudentRankingOrder,
					  s.IsNationalMeritScholar,
                      s.HighSchoolDiplomaDate, s.FPPSeniorPacket, ci.IsEnrolled, bf.BrightFutureName, ci.RemedialCollegeRequired, s.GraduationYear, ci.ExpectedGraduationDate,
					  ci.ActualGraduationDate, ci.Notes As CollegeNotes, ci.EntryDate, ci.PartTimeWork, et.EmploymentTypeName As EmploymentType, ci.TranscriptReceivedDate,
					  ci.DegreeAuditReceivedDate, ci.LastEnrolledDate As LastCollegeEnrollmentDate, ci.Graduate, ci.LastEnrolledDate, s.AlumniAlliance, s.BirthDate AS DOB, cm.CollegeMajorName, cl.CollegeLevelName, dg.DegreeTypeName,
					  'XXX - XX - ' + RIGHT(s.SSN, 4) AS SocialSec#   , s.HousingScholarship, s.HomePhoneNumber,  s.MobilePhoneNumber,
	(
		Select Top(1) Score as ACT From students.TestScores
		Where students.TestScores.StudentID = s.StudentID and TestTypeID = 1 and IsDeleted = 0
		Order By Score DESC
	) AS ACTScore,
	(
		Select Top(1) Score as SAT From students.TestScores
		Where students.TestScores.StudentID = s.StudentID and TestTypeID = 8 and IsDeleted = 0
		Order By Score DESC
	) AS SATScore,
	(
		Select Top(1) men.FirstName +' '+ men.LastName as MentorName From students.StudentMentors stm
		Left join mentors.Mentors men on men.MentorID = stm.MentorID
		Where stm.MentorID = men.MentorID and stm.StudentID = s.StudentID and stm.IsPrimary = 1 and stm.UnassignedDate is null and stm.MentorAssignmentTypeID = 1
		Order By stm.AssignedDate DESC
	) AS Mentor,
	(
		Select Top(1) LastTerm From Offices.Scholarships
		Where Offices.Scholarships.StudentID = s.StudentID
		Order By LastYearAttnd DESC
	) AS LastTermAttended,
	(
		Select Top(1) PlanType From Offices.Scholarships
		Where Offices.Scholarships.StudentID = s.StudentID
		Order By LastYearAttnd DESC
	) AS LastPlanType,
	(
		Select Top(1) ContractNumber From Offices.Scholarships
		Where Offices.Scholarships.StudentID = s.StudentID
		Order By LastYearAttnd DESC
	) AS LastContractNumber,
	(
		Select Top(1) LastYearAttnd From Offices.Scholarships
		Where Offices.Scholarships.StudentID = s.StudentID
		Order By LastYearAttnd DESC
	) AS LastYearAttended,
	(
		Select Top(1) ScholarshipOwner From Offices.Scholarships
		Where Offices.Scholarships.StudentID = s.StudentID
		Order By LastYearAttnd DESC
	) AS ScholarshipOwner,
	(
		Select Top(1) Donor From Offices.Scholarships
		Where Offices.Scholarships.StudentID = s.StudentID
		Order By LastYearAttnd DESC
	) AS Donor,
	(
		Select Top(1) SemesterUnweighted From Students.GPA
		Where Students.GPA.StudentID = s.StudentID
		And SemesterUnweighted > 0
		Order By SemesterEndDate DESC
	) AS LastSemesterUnweightedGPA,
	(
		Select Top(1) CumulativeUnweighted From Students.GPA
		Where Students.GPA.StudentID = s.StudentID
		And CumulativeUnweighted > 0
		Order By SemesterEndDate DESC
	) AS LastCumulativeUnweightedGPA ,
	(
		Select Top(1) Note From Students.Communications
		Where Students.Communications.StudentID = s.StudentID
		Order By NoteDate DESC
	) AS LastCommunicationNote
	,(	---- Added College GPA data   6/9/2015   JL
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
	,(
		Select FirstName + ' ' + LastName As AdvocateName
		From Offices.Staff
		Where s.AdvocateID = Offices.Staff.StaffID
	) As AdvocateName
FROM         Students.Students AS s
	LEFT OUTER JOIN Lookups.StudentStatuses AS ss ON s.StudentStatusID = ss.StudentStatusID
	LEFT OUTER JOIN Schools.Schools AS sch ON sch.SchoolID = s.SchoolID
	LEFT OUTER JOIN Offices.Offices AS o ON o.OfficeID = s.OfficeID
	--LEFT OUTER JOIN Students.CollegeApplications AS ca ON s.StudentID = ca.StudentID
	LEFT OUTER JOIN Students.CollegeInformation AS ci ON ci.StudentID = s.StudentID
	LEFT OUTER JOIN Lookups.Colleges AS SelCol ON SelCol.CollegeID = ci.CollegeID
	--LEFT OUTER JOIN Lookups.Colleges AS cols ON ca.CollegeID = cols.CollegeID
	LEFT OUTER JOIN Students.FAFSA AS sf ON s.StudentID = sf.StudentID
	LEFT OUTER JOIN Lookups.BrightFutures AS bf ON s.BrightFutureID = bf.BrightFutureID
	LEFT OUTER JOIN Lookups.EmploymentTypes et on ci.EmploymentTypeID = et.EmploymentTypeID
	LEFT OUTER JOIN Lookups.CollegeMajors cm ON ci.CollegeMajorID = cm.CollegeMajorID
	LEFT OUTER JOIN  Lookups.CollegeLevels cl ON ci.CollegeLevelID = cl.CollegeLevelID
	LEFT OUTER JOIN Lookups.DegreeTypes dg ON ci.CollegeDegreeTypeID = dg.DegreeTypeID
	INNER JOIN lookups.counties counties ON s.countyid=counties.countyid
WHERE  s.StudentStatusID IN (1,3,4,5,11,12,13,14,15,25,28)