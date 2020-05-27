SELECT     
	S.FirstName,
	S.MiddleName, 
	S.LastName, 
	S.LastName + ', ' + S.FirstName AS StudentFullName, 
	CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedSSN)) AS SSN,
	CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate)) AS BirthDate,
	SS.StudentStatusName, 
	GR.GradeLevelName AS CurrentGradeLevel, 
	DATENAME(MM, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate))) AS BirthdayMonth,
	RIGHT(N'0' + CONVERT(nvarchar(2), MONTH(CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate)))), 2) + '_' + DATENAME(MM, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate))) AS BirthdayNumberMonth,
	S.HomePhoneNumber, 
	S.MobilePhoneNumber, 
	S.WorkPhoneNumber, 
	S.EmailAddress, 
	CASE WHEN S.Gender = 'M' THEN 'Male' ELSE 'Female' END AS Gender,
	CNT.CountyName,
	SAddress.Address1 AS StudentAddress1,
	SAddress.Address2 AS StudentAddress2, 
	SAddress.City AS StudentCity, 
	SAddress.StateID AS StudentState, 
	SAddress.ZipCode AS StudentZipCode,
    (	SELECT	TOP (1) ContactName
		FROM	Students.Contacts AS PG
		WHERE	(StudentID = S.StudentID) AND (IsPrimaryGuardian = 1)
	) AS PrimaryGuardianName,
    (	SELECT	TOP (1) ContactName
		FROM	Students.Contacts AS SG
		WHERE	(StudentID = S.StudentID) AND (IsSecondaryGuardian = 1)
	) AS SecondaryGuardianName, 
	SC.SchoolName, 
    AD.FirstName + ' ' + AD.LastName AS AdvocateFullName,
	DATEDIFF(YY, S.BirthDate, GETDATE()) AS StudentAge,
    (	SELECT TOP (1) M.FirstName + ' ' + M.LastName AS MentorName
		FROM Students.StudentMentors AS SM 
		LEFT OUTER JOIN Mentors.Mentors AS M ON SM.MentorID = M.MentorID
		WHERE (SM.StudentID = S.StudentID) AND (SM.IsPrimary = 1)
	) AS MentorName, 
	S.IsHispanic, 
	R.RaceName, 
	S.OfficeID, 
	S.Gender AS StudentGender,
	S.GraduationYear,
	S.EntryGPA, 
	S.EntryGradeLevelID,
	(	SELECT TOP (1) SSM.AssignedDate
		FROM	Students.StudentMentors SSM 
		WHERE   SSM.STudentID = S.StudentID AND SSM.AssignedDate Between '2019-06-06' AND '2020-06-30'
		ORDER BY   SSM.AssignedDate
	) AS MentorMatchDate, -- Added order by above to pick the first match for 90 day compliance.  JL 05/12/2014
    S.CurrentGradeLevelID, 
	S.HighSchoolDiplomaDate,    
	S.PriorityType, 
	S.ContractSignedDate, 
	APP.GPA, 
	APP.PriorityType AS AppStudType, 
    S.EntryGradeLevelID AS EntryGradeLevel, 
	OO.OfficeName,
	CASE WHEN S.WfiEligible = 1 THEN 'Y' ELSE 'N' END AS WfiEligible,
	CASE WHEN S.EnrollmentVariance = 1 THEN 'Y' ELSE 'N' END AS EnrollmentVariance,
	ISNULL(S.EnrollmentVarianceNote, '') AS EnrollmentVarianceNote
FROM 
	Students.Students AS S 
	LEFT OUTER JOIN Students.Applications AS APP ON APP.StudentID = S.StudentID 
	LEFT OUTER JOIN Lookups.Counties AS CNT ON S.CountyID = CNT.CountyID 
	LEFT OUTER JOIN Schools.Schools AS SC ON S.SchoolID = SC.SchoolID 
	LEFT OUTER JOIN Lookups.StudentStatuses AS SS ON S.StudentStatusID = SS.StudentStatusID 
	LEFT OUTER JOIN Common.Addresses AS SAddress ON S.AddressID = SAddress.AddressID 
	LEFT OUTER JOIN Lookups.Ethnicities AS E ON S.EthnicityID = E.EthnicityID 
	LEFT OUTER JOIN Lookups.GradeLevels AS GR ON S.CurrentGradeLevelID = GR.GradeLevelID 
	LEFT OUTER JOIN Lookups.Races AS R ON S.RaceID = R.RaceID 
	LEFT OUTER JOIN Offices.Staff AS AD ON S.AdvocateID = AD.StaffID  
	LEFT OUTER JOIN Offices.Offices OO ON OO.OfficeID = S.OfficeID
WHERE     (S.StudentStatusID IN (1,3,4,5)) AND
		  (S.ContractSignedDate BETWEEN '2019-06-06' AND '2020-06-06')
		--- And S.CountyID = 13 -- Miami-Dade
