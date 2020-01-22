with 

MentorNamesCte (StudentID, Mentors) As
	(
		Select Main.StudentID,
       Left(Main.Mentors,Len(Main.Mentors)-1) As "Mentors"
From(Select distinct ST2.StudentID, 
           (Select ST1.FirstName + ' ' + ST1.LastName + ', ' AS [text()]
            From Mentors.Mentors ST1
				Left Outer Join Students.StudentMentors SMS ON ST1.MentorID = SMS.MentorID
            Where SMS.StudentID = ST2.StudentID 
				--AND (SMS.UnassignedDate > '2013-08-01' OR SMS.UnassignedDate IS NULL)
				AND SMS.AssignedDate <= CONVERT (date, GETDATE())
				AND (SMS.UnassignedDate IS NULL)
				AND (SMS.MentorAssignmentTypeID = 1)
            For XML PATH ('')) [Mentors]
     From Students.Students ST2) [Main]
	 --ORDER BY Main.StudentID
	),


	MentorAssignedDate (AssignedDate, StudentID, OfficeID) As
	(
		Select MIN(sms.AssignedDate) As AssignedDate
		
			,ss.StudentID,
			ss.OfficeID
		From Students.StudentMentors sms 
			Join Students.Students ss
				On ss.StudentID = sms.StudentID
		Where ss.StudentStatusID 
				In (1, 3, 4, 5) -- All active except "On Hold" 
			--And ss.ContractSignedDate  
			--	< '2014-06-30'
			--And (sms.UnassignedDate > '2013-08-01' OR SMS.UnassignedDate IS NULL)
			And (SMS.UnassignedDate IS NULL)
			AND SMS.MentorAssignmentTypeID = 1
			--AND SMS.IsPrimary = 1
						And SMS.IsDeleted = 0
		Group By ss.StudentID, ss.OfficeID
		--Order By ss.StudentID --for testing
	)

Select s.FirstName
	,s.LastName
	,StudentStatusName
	,SchoolName
	,s.CurrentGradeLevelID
	,ofs.FirstName +' '+ ofs.LastName as AdvocateName
	,mn.Mentors
	,mad.AssignedDate
	,lc.CountyName
	--,ms.SessionDate
	
	
	
	,(Select Count(mss.SessionDate) as #Sessions
		From students.MentoringSessions mss
		where (mss.StudentID = s.StudentID) and (mss.IsDeleted = 0)	and (mss.SessionDate between '2018-07-01' and '2019-06-30')
		) as TotalMentorSessions
		 
	,(Select Sum(mss.SessionDuration) as #Mins
			From students.MentoringSessions mss
			where (mss.StudentID = s.StudentID) and (mss.IsDeleted = 0)	and (mss.SessionDate between '2018-07-01' and '2019-06-30')
			) as TotalMentorMinutes

	,(Select cast(Round((Sum(mss.SessionDuration))/60.0,1) as float) --as #Hours
		From students.MentoringSessions mss
		where (mss.StudentID = s.StudentID) and (mss.IsDeleted = 0)	and (mss.SessionDate between '2018-07-01' and '2019-06-30')
		) as TotalMentorHours

	,(Select Count(scs.NoteDate) as #visits
		From Students.Communications scs
		where (scs.StudentID = s.StudentID) and (scs.StudentCommunicationTypeID = 1) and (scs.IsDeleted = 0) and (scs.NoteDate between '2018-07-01' and '2019-06-30')	
		) as TotalCRVisits


	,s.OfficeID
	,s.Affiliation
	,s.ContractSignedDate

	


	From Students.Students s
	left outer join Lookups.StudentStatuses ss on s.StudentStatusID = ss.StudentStatusID
	left outer join schools.Schools scls on s.SchoolID = scls.SchoolID
	left outer join offices.Staff ofs on s.AdvocateID = ofs.StaffID
	left outer join Lookups.Counties lc on s.CountyID = lc.CountyID
	left outer join MentorNamesCte mn on mn.StudentID = s.StudentID
	left outer join MentorAssignedDate mad on mad.StudentID = s.StudentID
	--left outer  join Students.MentoringSessions ms on s.StudentID = ms.StudentID
	--From students.students
	where s.StudentStatusID in (1,3,4,5) and s.IsDeleted = 0 
	group by s.FirstName, s.LastName, s.StudentID, ss.StudentStatusName, SchoolName, s.CurrentGradeLevelID,
	ofs.FirstName, ofs.LastName, lc.CountyName,s.Affiliation, s.ContractSignedDate, s.OfficeID,mn.Mentors, mad.AssignedDate
	--order by s.LastName
