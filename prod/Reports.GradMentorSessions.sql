SELECT     s.LastName + ', ' + s.FirstName AS StudentName, s.MiddleName, m.LastName + ', ' + m.FirstName As MentorName, sm.MentorAssignmentTypeID,
					  s.StudentStatusID, s.GraduationYear, s.StudentReferenceID, s.OfficeID, s.ContractSignedDate, ss.StudentStatusName,
                      sch.SchoolName, c.CountyName, sms.SessionDate, sms.SessionNote, sms.SessionDuration, s.Affiliation,
					  s.i3ControlGroup, i3StudyGroupMember, MentorStatusName  --, os.Donor
					  --( Select Top (1) Donor
					  --  From Offices.Scholarships
					  --  Where Offices.Scholarships.StudentID = s.StudentID and Offices.Scholarships.isdeleted = 0) As DonorName
FROM         Students.Students AS s INNER JOIN
                      Lookups.StudentStatuses AS ss ON s.StudentStatusID = ss.StudentStatusID INNER JOIN
                      Schools.Schools AS sch ON s.SchoolID = sch.SchoolID INNER JOIN
                      Lookups.Counties AS c ON s.CountyID = c.CountyID LEFT OUTER JOIN
					 -- Offices.Scholarships os ON s.StudentID = os.StudentID LEFT OUTER JOIN
					  Students.StudentMentors AS sm ON s.StudentID = sm.StudentID
						--AND (sm.UnassignedDate < '2017-08-01' OR sm.UnassignedDate IS NULL)
						--AND sm.MentorAssignmentTypeID = 1
						INNER JOIN
					  Mentors.Mentors AS m ON sm.MentorID = m.MentorID LEFT OUTER JOIN
					  Students.MentoringSessions AS sms ON s.StudentID = sms.StudentID
							--And sms.SessionDuration > 0
							AND m.MentorID = sms.MentorID INNER JOIN
					  Lookups.MentorStatuses ms ON m.MentorStatusID = ms.MentorStatusID

			Where s.StudentStatusID IN (11,12,13,14,15,25,27)
			And s.IsDeleted = 0
			And m.IsDeleted = 0
			And sm.IsDeleted = 0
			And sms.IsDeleted = 0
			--and s.OfficeID = 6
			---and s.GraduationYear = 2017
			--and sms.SessionDate between '2016-08-01' and '2017-06-30'