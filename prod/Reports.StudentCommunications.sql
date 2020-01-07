SELECT
    S.LastName,
    S.FirstName,
    S.MiddleName,
    S.CurrentGradeLevelID,
    AD.FirstName + ' ' + AD.LastName AS AdvocateFullName,
    Lookups.StudentStatuses.StudentStatusName,
    Schools.Schools.SchoolName,
    SCT.StudentCommunicationTypeName,
    SC.NoteDate,
    Lcm.CommunicationMethodName,
    S.ContractSignedDate,
    S.StudentReferenceID As StudentID,
    CASE
        WHEN SC.EnteredByID <> 0 THEN (SELECT COALESCE(FirstName + ' '+ LastName, 'Unknown') FROM Offices.Staff WHERE StaffID = sC.EnteredByID)
        ELSE 'State User'
    END AS EnteredByName,
    Common.GetUserActualName(SC.RecordedByID) AS RecordedByName,
    SC.Note,
    S.OfficeID,
    C.CountyName,
    s.Affiliation
FROM
    Students.Students S
LEFT JOIN Students.Communications SC ON S.StudentID = SC.StudentID
LEFT JOIN Lookups.StudentCommunicationTypes SCT ON SC.StudentCommunicationTypeID = SCT.StudentCommunicationTypeID
LEFT JOIN lookups.CommunicationMethods lcm on lcm.CommunicationMethodId = sc.CommunicationMethodID
LEFT JOIN Offices.Staff AD ON S.AdvocateID = AD.StaffID
LEFT JOIN Lookups.StudentStatuses ON S.StudentStatusID = Lookups.StudentStatuses.StudentStatusID
LEFT JOIN Schools.Schools ON S.SchoolID = Schools.Schools.SchoolID
LEFT JOIN  Lookups.Counties C on S.CountyID = C.CountyID

WHERE		SC.IsDeleted = 0