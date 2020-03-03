SELECT     
   S.FirstName, 
   S.MiddleName, 
   S.LastName, 
   S.LastName + ', ' + S.FirstName AS StudentFullName, 
   S.SSN, 	   
   o.officename, 
   s.graduationyear, 
   M.EmailAddress as MentorEmail, 
   S.BirthDate, 
   SS.StudentStatusName, 
   GR.GradeLevelName AS CurrentGradeLevel, 
   s.StudentID as STARID, 
   DATENAME(MM, S.BirthDate) AS BirthdayMonth, 
   RIGHT(N'0' + CONVERT(nvarchar(2), MONTH(S.BirthDate)), 2) + '_' + DATENAME(MM, S.BirthDate) AS BirthdayNumberMonth, 
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
   S.PriorityType, 
   CT.ContractTypeName,
  SAddress.ZipCode AS StudentZipCode, 
   (Select TOP(1) AgencyName From Offices.Contacts oc Where o.OfficeID = oc.OfficeID And oc.IsDeleted = 0 And AgencyName IS NOT NULL) As AgencyName
  ,(Select replace(replace(Left(Main.Mentors,Len(Main.Mentors)-1), char(10), ''), char(13), '')     As "Notes"
    From (Select distinct ST2.StudentID, (Select convert(varchar(20), SNS.NoteDate, 120) + ' - ' + SNS.Note + '. ' AS [text()] 
				          FROM Students.Notes SNS 
					  Where SNS.StudentID = ST2.StudentID 
					  AND (SNS.Note IS NOT NULL)
					  For XML PATH ('NOTE')
					 ) [Mentors]
					From Students.Students ST2) [Main]
					Where Main.StudentID = S.StudentID) As StudentNotes,
  (SELECT     TOP (1) ContactName
    FROM          Students.Contacts AS PG
    WHERE      (StudentID = S.StudentID) and (IsPrimaryGuardian = 1) and (pg.IsDeleted = 0)) AS PrimaryGuardianName,
  (SELECT     TOP (1) ContactName
    FROM          Students.Contacts AS SG
    WHERE      (StudentID = S.StudentID) AND (IsSecondaryGuardian = 1) and (SG.IsDeleted = 0)) AS SecondaryGuardianName,
(SELECT     TOP (1) sct.StudentContactTypeName
    FROM          Students.Contacts AS PG
   left join lookups.StudentContactTypes sct on pg.StudentContactTypeID = sct.StudentContactTypeID
    WHERE      (StudentID = S.StudentID) and (IsPrimaryGuardian = 1) and (pg.IsDeleted = 0)) AS PrimaryGuardianRelation,
(SELECT     TOP (1) sct.StudentContactTypeName
    FROM          Students.Contacts AS SG
    left join lookups.StudentContactTypes sct on SG.StudentContactTypeID = sct.StudentContactTypeID
    WHERE      (StudentID = S.StudentID) AND (IsSecondaryGuardian = 1) and (SG.IsDeleted = 0)) AS SecondaryGuardianRelation,
(SELECT     TOP (1) EmailAddress
    FROM          Students.Contacts AS PGE
    WHERE      (StudentID = S.StudentID) and (IsPrimaryGuardian = 1) and (PGE.IsDeleted = 0)) AS PrimaryGuardianEmail,
(SELECT     TOP (1) EmailAddress
    FROM          Students.Contacts AS SGE
    WHERE      (StudentID = S.StudentID) and (IsSecondaryGuardian = 1) and (SGE.IsDeleted = 0)) AS SecondaryGuardianEmail,
(SELECT     TOP (1) pge.ContactCellPhone
    FROM          Students.Contacts AS PGE
    WHERE      (StudentID = S.StudentID) and (IsPrimaryGuardian = 1) and (PGE.IsDeleted = 0)) AS PrimaryGuardianNumber,
(SELECT     TOP (1) sge.ContactCellPhone
    FROM          Students.Contacts AS SGE
    WHERE      (StudentID = S.StudentID) and (IsSecondaryGuardian = 1) and (SGE.IsDeleted = 0)) AS SecondaryGuardianNumber,
(SELECT     TOP (1) sga.SemesterUnweighted
    FROM          Students.GPA AS SGA
    WHERE      (StudentID = S.StudentID) and (sga.IsDeleted = 0) order by sga.SemesterEndDate DESC) AS LastSemesterUnweightedGPA,
	s.CommunityServiceHours,
	SC.SchoolName, 
      AD.FirstName + ' ' + AD.LastName AS AdvocateFullName, 
    DATEDIFF(YY, S.BirthDate, GETDATE()) AS StudentAge
  	,M.FirstName + ' ' + M.LastName AS MentorName, 
	  m.firstname AS MentorFirstName,
	  m.lastname AS MentorLastName,
	  m.MobilePhoneNumber as MentorMobile, m.HomePhoneNumber as MentorHomePhone,
     S.IsHispanic,
     R.RaceName,
     SI.InterestName,
     0 AS SomeNewField,
  	(  
	   SELECT SUM(DaysUnExcused) AS TotalDaysExcused
           FROM          Students.Attendance
           WHERE      (StudentID = S.StudentID)
	) AS DaysUnExcused, 
     S.OfficeID, 
     S.ContractSignedDate, 
     s.StudentReferenceID, 
     S.HighSchoolDiplomaDate,
     S.ProbationLevelID, 
	PR.ProbationReasonName,
	( 
		SELECT TOP(1) SH.StatusChangeDate
		FROM Students.StatusHistory SH
		WHERE S.StudentID = SH.StudentID
		ORDER BY SH.StatusChangeDate DESC
	) As LastStatusChangeDate,
	( 
		SELECT TOP(1) SA.ApplicationStartDate
		FROM Students.Applications SA
		WHERE S.StudentID = SA.StudentID
		ORDER BY SA.ApplicationStartDate DESC
	) As ApplicationStartDate,
	( 
		SELECT TOP(1) SA.ApplicationReadyDate
		FROM Students.Applications SA
		WHERE S.StudentID = SA.StudentID
		ORDER BY SA.ApplicationReadyDate DESC
	) As ApplicationReadyDate,
	( 
		SELECT TOP(1) SA.ApplicationCompletionDate
		FROM Students.Applications SA
		WHERE S.StudentID = SA.StudentID
		ORDER BY SA.ApplicationCompletionDate DESC
	) As ApplicationCompletionDate,
	( 
		SELECT TOP(1) YEAR(SA.ApplicationStartDate)
		FROM Students.Applications SA
		WHERE S.StudentID = SA.StudentID
		ORDER BY SA.ApplicationStartDate DESC
	) As ApplicationStartYear,
	( 
		SELECT TOP(1) YEAR(SA.ApplicationCompletionDate)
		FROM Students.Applications SA
		WHERE S.StudentID = SA.StudentID
		ORDER BY SA.ApplicationCompletionDate DESC
	) As ApplicationCompletionYear,
	( 
		SELECT TOP(1) SA.ApplicationStage
		FROM Students.Applications SA
		WHERE S.StudentID = SA.StudentID
		ORDER BY SA.ApplicationStartDate DESC
	) As ApplicationStage,
	( 
		SELECT TOP(1) CA.Address1 + ' ' + CA.Address2 As Adress
		FROM Students.Applications SA
		LEFT OUTER JOIN Common.Addresses CA ON SA.AddressID = CA.AddressID
		WHERE S.StudentID = SA.StudentID
		ORDER BY SA.ApplicationStartDate DESC
	) As ApplicationAddress,
	( 
		SELECT TOP(1) CA.City
		FROM Students.Applications SA
		LEFT OUTER JOIN Common.Addresses CA ON SA.AddressID = CA.AddressID
		WHERE S.StudentID = SA.StudentID
		ORDER BY SA.ApplicationStartDate DESC
	) As ApplicationCity,
	( 
		SELECT TOP(1) CA.StateID
		FROM Students.Applications SA
		LEFT OUTER JOIN Common.Addresses CA ON SA.AddressID = CA.AddressID
		WHERE S.StudentID = SA.StudentID
		ORDER BY SA.ApplicationStartDate DESC
	) As ApplicationState,
	( 
		SELECT TOP(1) CA.ZipCode
		FROM Students.Applications SA
		LEFT OUTER JOIN Common.Addresses CA ON SA.AddressID = CA.AddressID
		WHERE S.StudentID = SA.StudentID
		ORDER BY SA.ApplicationStartDate DESC
	) As ApplicationZipCode,
	( 
		SELECT TOP(1) SA.HomePhoneNumber
		FROM Students.Applications SA
		WHERE S.StudentID = SA.StudentID
		ORDER BY SA.ApplicationStartDate DESC
	) As ApplicationHomePhone,
	( 
		SELECT TOP(1) SA.MobilePhoneNumber
		FROM Students.Applications SA
		WHERE S.StudentID = SA.StudentID
		ORDER BY SA.ApplicationStartDate DESC
	) As ApplicationMobilePhone,
	( 
		SELECT TOP(1) SA.EmailAddress
		FROM Students.Applications SA
		WHERE S.StudentID = SA.StudentID
		ORDER BY SA.ApplicationStartDate DESC
	) As ApplicationEmailAddress,
	S.Affiliation,
	( 
		SELECT TOP(1) SA.PriorityType
		FROM Students.Applications SA
		WHERE S.StudentID = SA.StudentID
		ORDER BY SA.ApplicationStartDate DESC
	) As ApplicationPriorityType

	,'' as Blank
	,'' as Blank2						

FROM         Students.Students AS S LEFT OUTER JOIN Offices.Offices o on s.OfficeID = o.OfficeID 
--left outer join offices.Contacts oc on o.OfficeID = oc.OfficeID 
left outer join Lookups.Counties AS CNT ON S.CountyID = CNT.CountyID 
LEFT OUTER JOIN Schools.Schools AS SC ON S.SchoolID = SC.SchoolID 
LEFT OUTER JOIN lookups.ContractTypes ct on s.ContractTypeID = ct.ContractTypeID 
--LEFT OUTER JOIN--Students.Contacts as spc on s.StudentID = spc.StudentID 
Left Outer Join Lookups.StudentStatuses AS SS ON S.StudentStatusID = SS.StudentStatusID 
LEFT OUTER JOIN Common.Addresses AS SAddress ON S.AddressID = SAddress.AddressID 
LEFT OUTER JOIN Lookups.Ethnicities AS E ON S.EthnicityID = E.EthnicityID 
LEFT OUTER JOIN Lookups.GradeLevels AS GR ON S.CurrentGradeLevelID = GR.GradeLevelID 
LEFT OUTER JOIN Students.StudentMentors AS SM ON S.StudentID = SM.StudentID AND SM.IsPrimary = 1 AND SM.UnassignedDate IS NULL 
LEFT OUTER JOIN Mentors.Mentors AS M ON SM.MentorID = M.MentorID 
LEFT OUTER JOIN Lookups.Races AS R ON S.RaceID = R.RaceID 
LEFT OUTER JOIN Offices.Staff AS AD ON S.AdvocateID = AD.StaffID 
LEFT OUTER JOIN Lookups.Interests SI ON S.InterestID = SI.InterestID 
LEFT OUTER JOIN Lookups.ProbationReasons PR ON S.ProbationReasonID = PR.ProbationReasonID
WHERE       S.IsDeleted = 0 --and s.officeid = 33
