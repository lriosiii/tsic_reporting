SELECT DISTINCT 
	s.LastName, 
	s.FirstName, 
	s.StudentReferenceID, 
	s.SSN, s.LastName + ', ' + s.FirstName AS StudentFullName, 
	s.MiddleName,
	ss.StudentStatusName, 
	s.EmailAddress As StudentEmail, 
	s.OfficeID, 
	s.CountyID, 
	sch.SchoolName, 
	c.OfficeName, 
    Gr.ContactName AS GaurdianFullName, 
	Adr.Address1 + ' ' + Adr.Address2 AS GaurdianAddress, 
	Adr.City + ' ' + Adr.StateID AS GaurdianCityState, 
    Adr.ZipCode AS GaurdianZip, 
	Gr.EmailAddress AS GaurdianEmail, 
	Gr.ContactHomePhone AS GaurdianHomePh, 
	Gr.ContactCellPhone AS GaurdianCellPh, 
    Gr.IsPrimaryGuardian, 
	Gr.IsSecondaryGuardian, 
	s.CurrentGradeLevelID, 
	s.GraduationYear, 
	r.RaceName, 
	s.ContractSignedDate, 
	s.MobilePhoneNumber As StudentCellPhone,
	(
		Select lr.RiskFactorName 
		From Lookups.RiskFactors lr
		INNER JOIN Students.ApplicationRiskFactors ar On ar.RiskFactorID = lr.RiskFactorID
		INNER JOIN Students.Applications sa ON sa.ApplicationID = ar.ApplicationID And sa.StudentID = s.StudentID
		Where lr.RiskFactorID = 23
	) As RiskFactor, 
	sa.GPA As ApplicationGPA, 
	sa.ApplicationOnFile

FROM	Students.Students AS s
INNER JOIN Offices.Offices AS c ON c.OfficeID = s.OfficeID
LEFT OUTER JOIN Students.Applications sa on s.StudentID = sa.StudentID
LEFT OUTER JOIN Lookups.Races r ON s.RaceID = r.RaceID
LEFT OUTER JOIN Students.Contacts AS Gr ON s.StudentID = Gr.StudentID
LEFT OUTER JOIN Lookups.EducationLevels El on Gr.EducationLevelID = El.EducationLevelID
INNER JOIN Lookups.StudentStatuses AS ss ON s.StudentStatusID = ss.StudentStatusID
LEFT JOIN Schools.Schools AS sch ON s.SchoolID = sch.SchoolID
LEFT OUTER JOIN Common.Addresses AS Adr ON Gr.AddressID = Adr.AddressID

where gr.IsDeleted = 0
