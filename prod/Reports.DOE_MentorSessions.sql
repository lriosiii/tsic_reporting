SELECT  
	DISTINCT  
	sms.SessionDate,  
	sms.SessionDuration, 
	s.StudentID, 
	m.MentorID, 
	s.LastName + ', ' + s.FirstName AS StudentName, 
	s.MiddleName, 
	m.LastName + ', ' + m.FirstName As MentorName, 
	s.StudentStatusID, 
	s.CurrentGradeLevelID, 
	s.ContractSignedDate, 
	ss.StudentStatusName,
    	sch.SchoolName,
	c.CountyName,
	o.OfficeName,
	sm.AssignedDate,
	--LEFT(sms.SessionNote, 1) As Note,
	MentorStatusName
FROM
	Students.Students AS s
INNER JOIN Lookups.StudentStatuses AS ss ON s.StudentStatusID = ss.StudentStatusID
INNER JOIN Offices.Offices o ON s.OfficeID = o.OfficeID
Inner JOIN Schools.Schools AS sch ON s.SchoolID = sch.SchoolID
INNER JOIN Lookups.Counties AS c ON s.CountyID = c.CountyID
LEFT OUTER JOIN Students.StudentMentors AS sm ON s.StudentID = sm.StudentID
	--AND (sm.UnassignedDate < '2013-08-01' OR sm.UnassignedDate IS NULL)
	--AND sm.MentorAssignmentTypeID = 1
INNER JOIN Mentors.Mentors AS m ON sm.MentorID = m.MentorID
LEFT OUTER JOIN Students.MentoringSessions AS sms ON s.StudentID = sms.StudentID
	And sms.SessionDuration > 0
	And m.MentorID = sms.MentorID
INNER JOIN Lookups.MentorStatuses ms ON m.MentorStatusID = ms.MentorStatusID

Where s.StudentStatusID IN (1,3,4,5)
And s.IsDeleted = 0
And m.IsDeleted = 0
And sm.IsDeleted = 0
And sms.IsDeleted = 0
And (sms.SessionNote IS NOT NULL OR sms.SessionNote <> '')
