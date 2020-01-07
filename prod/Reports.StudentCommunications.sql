SELECT     S.LastName, S.FirstName, S.MiddleName, S.CurrentGradeLevelID, AD.FirstName + ' ' + AD.LastName AS AdvocateFullName, Lookups.StudentStatuses.StudentStatusName,
                      Schools.Schools.SchoolName, SCT.StudentCommunicationTypeName, SC.NoteDate, Lcm.CommunicationMethodName,
					  S.ContractSignedDate, S.StudentReferenceID As StudentID, SC.Note, S.OfficeID, C.CountyName, s.Affiliation
FROM         Students.Students S
						Left OUTER JOIn Students.Communications SC ON S.StudentID = SC.StudentID
						left JOIN Lookups.StudentCommunicationTypes SCT ON SC.StudentCommunicationTypeID = SCT.StudentCommunicationTypeID
						left join lookups.CommunicationMethods lcm on lcm.CommunicationMethodId = sc.CommunicationMethodID
						left JOIN Offices.Staff AD ON S.AdvocateID = AD.StaffID
						left JOIN Lookups.StudentStatuses ON S.StudentStatusID = Lookups.StudentStatuses.StudentStatusID
						left JOIN Schools.Schools ON S.SchoolID = Schools.Schools.SchoolID
						LEFT OUTER JOIN  Lookups.Counties C on S.CountyID = C.CountyID
WHERE		SC.IsDeleted = 0