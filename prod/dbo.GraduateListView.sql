WITH LastEnteredCollege AS
	(
		SELECT C1.StudentID, LC.CollegeID, C2.LastUpdatedDateTime, LC.CollegeName, CL.CollegeLevelName, C2.IsEnrolled, C2.LastEnrolledDate, CC.CollegeCampusName
		FROM (
			Select StudentID, MAX(LastEnrolledDate) as MaxUpdatedDateTime
			FROM Students.CollegeInformation
         WHERE (IsDeleted = 0)
			GROUP by StudentID) AS C1
		LEFT JOIN Students.CollegeInformation AS C2
		ON C2.StudentID = C1.StudentID AND C2.LastEnrolledDate = C1.MaxUpdatedDateTime AND C2.IsDeleted = 0

		LEFT OUTER JOIN Lookups.Colleges LC ON C2.CollegeID = LC.CollegeID
		LEFT OUTER JOIN Lookups.CollegeLevels CL ON C2.CollegeLevelID = CL.CollegeLevelID
		LEFT OUTER JOIN Lookups.CollegeCampuses CC ON C2.CollegeCampusID = CC.CollegeCampusID
	)

	-- Create subset with only requested students
	SELECT S.StudentID,
 		S.StudentStatusID,
 		SS.StudentStatusName,
 		SG.StatusGroupID,
 		SG.StatusGroupName,
		S.SSN,
		S.FirstName,
		S.MiddleName,
		S.LastName,
		S.AddressID,
		S.BirthDate,
		S.GraduationYear,
		LE.CollegeName,
		LE.CollegeLevelName,
        ST.[FirstName] + ' ' + ST.[LastName] AS CollegeCompletionCoach,
		DATEDIFF(yy,S.BirthDate,GETDATE()) as Age,
		GL.GradeLevelName,
		CASE WHEN S.Gender = 'M' THEN 'Male' ELSE 'Female' END as Gender,
		S.OfficeID,
		COALESCE(SC.SchoolName, 'Not Specified') as SchoolName,
		COALESCE(A.FirstName + ' ' + A.LastName, 'Unassigned') as AdvocateName,
		COALESCE(SM1.MentorName, 'Unassigned') as MentorName,
		S.IsDeleted,
        LE.LastEnrolledDate,
        DATENAME(yyyy, LE.LastEnrolledDate) AS ColLastYearAttnd,
        CASE WHEN DATEPART(ww, LE.LastEnrolledDate) >= 33 THEN 'Fall'
			 WHEN DATEPART(ww, LE.LastEnrolledDate) >= 20 THEN 'Summer'
             WHEN DATEPART(ww, LE.LastEnrolledDate) >= 1 THEN 'Spring'
			 ELSE ''
		END AS ColLastTermAttnd,
		LE.CollegeCampusName
	FROM Students.Students S
		INNER JOIN Lookups.StudentStatuses SS ON S.StudentStatusID = SS.StudentStatusID
		INNER JOIN Lookups.StatusGroups SG ON SS.StatusGroupID = SG.StatusGroupID
		LEFT OUTER JOIN Schools.Schools SC ON S.SchoolID = SC.SchoolID
		LEFT OUTER JOIN LastEnteredCollege LE ON S.StudentID = LE.StudentID

		LEFT OUTER JOIN Lookups.CollegeRegionCampuses CC ON LE.CollegeID = CC.CollegeID
        LEFT OUTER JOIN State.Staff ST ON ST.CollegeRegionID = CC.CollegeRegionID AND ST.IsCollegeCompletionCoach = 1

		LEFT OUTER JOIN Offices.Staff A ON S.AdvocateID = A.StaffID
		LEFT OUTER JOIN Lookups.GradeLevels GL ON S.CurrentGradeLevelID = GL.GradeLevelID
		LEFT OUTER JOIN (SELECT SM.StudentID, M.FirstName + ' ' + M.LastName as MentorName
						FROM Students.StudentMentors SM
							INNER JOIN Mentors.Mentors M ON M.MentorID = SM.MentorID
						WHERE SM.IsPrimary = 1 AND SM.UnassignedDate IS NULL) SM1 ON S.StudentID = SM1.StudentID

	WHERE S.StudentStatusID in (11,12,13,14,15,25,27,28)