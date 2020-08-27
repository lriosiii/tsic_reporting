    /* COVID19 template meant to include sessions for unmatched mentee/mentor pairs  */
    
WITH -- Common CTE for total active students for the time period (for mentor match rates, etc)
	 totalMentorSessionsCte (TotalMentorSessions, StudentID, OfficeID) As
	(
		Select Count(sms.StudentID) As TotalMentorSessions,
			ss.StudentID,
			ss.OfficeID
		From Students.MentoringSessions sms
			Join Students.Students ss
				On ss.StudentID = sms.StudentID
		Where ss.StudentStatusID
				In (1, 3, 4, 5) -- All active except "On Hold"
			And sms.SessionDate Between '2020-07-01' AND '2021-06-30'
			And sms.IsDeleted = 0
			And sms.SessionDuration > 0
			And sms.MentorID IN
			(Select MentorID
			 FROM Students.StudentMentors
			 Where StudentID = ss.StudentID
			 And (UnassignedDate IS NULL Or UnassignedDate = '')
			 AND MentorAssignmentTypeID = 1)
		Group By ss.StudentID, ss.OfficeID
	),

	-- CTE for last mentor/student session date
	LastMentorSessionDate (LastSessionDate, StudentID, OfficeID) As
	(
		Select MAX(sms.SessionDate) As LastSessionDate,
			ss.StudentID,
			ss.OfficeID

		From Students.MentoringSessions sms
			Join Students.Students ss
				On ss.StudentID = sms.StudentID
		Where ss.StudentStatusID
				In (1, 3, 4, 5) -- All active except "On Hold"
			And sms.IsDeleted = 0
			And sms.SessionDuration > 0
			And sms.SessionDate Between '2020-07-01' AND '2021-06-30'
			And sms.MentorID IN
			(Select MentorID
			 FROM Students.StudentMentors
			 Where StudentID = ss.StudentID
			 And (UnassignedDate IS NULL Or UnassignedDate = '')
			 AND MentorAssignmentTypeID = 1)
		Group By ss.StudentID, ss.OfficeID
	),

	---- CTE for last mentor/student session date
	FirstMentorSessionDate (FirstSessionDate, StudentID, OfficeID) As
	(
		Select MIN(sms.SessionDate) As FirstSessionDate,
			ss.StudentID,
			ss.OfficeID
		From Students.MentoringSessions sms
			Join Students.Students ss
				On ss.StudentID = sms.StudentID
		Where ss.StudentStatusID
				In (1, 3, 4, 5) -- All active except "On Hold"
			--And ss.ContractSignedDate
			--	< '2014-06-30'
			And sms.IsDeleted = 0
			And sms.SessionDuration > 0
			And sms.SessionDate Between '2020-07-01' AND '2021-06-30'
			And sms.MentorID IN
			(Select MentorID
			 FROM Students.StudentMentors
			 Where StudentID = ss.StudentID
			 And (UnassignedDate IS NULL Or UnassignedDate = '')
			 AND MentorAssignmentTypeID = 1)
		Group By ss.StudentID, ss.OfficeID
		--Order By ss.StudentID --for testing
	),

	-- CTE for mentor/student assigned date
	MentorAssignedDate (AssignedDate, DTU, StudentID, OfficeID) As
	(
		Select MIN(sms.AssignedDate) As AssignedDate,
			Case when Convert (date, GETDATE()) > '2021-06-01'
			Then '2021-06-01'
			Else
			CONVERT(date, GetDate())
		End As DateTU
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
	),

	-- CTE for mentor names they were matched to
	MatchedMentorNamesCte (StudentID, Mentors, MentorEmails) As
	(
		Select Main.StudentID,
       Left(Main.Mentors,Len(Main.Mentors)-1) As "Mentors",
	   Main.Mentorsemails as MentorEmail
        From(Select distinct ST2.StudentID,
           (Select ST1.FirstName + ' ' + ST1.LastName + ', ' AS [text()]
            From Mentors.Mentors ST1
				Left Outer Join Students.StudentMentors SMS ON ST1.MentorID = SMS.MentorID
            Where SMS.StudentID = ST2.StudentID
				--AND (SMS.UnassignedDate > '2013-08-01' OR SMS.UnassignedDate IS NULL)
				AND SMS.AssignedDate >= '2020-07-01'
				AND (SMS.UnassignedDate IS NULL)
				AND (SMS.MentorAssignmentTypeID = 1)
            For XML PATH ('')) [Mentors],


			(Select ST1.EmailAddress + '  ' AS [text()]
		   --st1.EmailAddress AS [text()]
            From Mentors.Mentors ST1
				Left Outer Join Students.StudentMentors SMS ON ST1.MentorID = SMS.MentorID
            Where SMS.StudentID = ST2.StudentID
				--AND (SMS.UnassignedDate > '2013-08-01' OR SMS.UnassignedDate IS NULL)
				AND SMS.AssignedDate >= '2020-07-01'
				AND (SMS.UnassignedDate IS NULL)
				AND (SMS.MentorAssignmentTypeID = 1)
            For XML PATH ('')
			) [Mentorsemails]
     From Students.Students ST2) [Main]
	)


SELECT S.firstname                       AS menteeFirstName,
       s.LastName                        AS menteeLastName,
       m.FirstName                       AS mentorFirstName,
       m.LastName                        AS mentorLastName,
       st.LastName + ', ' + st.FirstName as AdvocateName,
       --sm.MentorAssignmentTypeID,
       s.StudentStatusID,
       s.StudentReferenceID,
       s.OfficeID,
       s.CurrentGradeLevelID,
       s.ContractSignedDate,
       ss.StudentStatusName,
       sch.SchoolName,
       c.CountyName,
       sms.SessionDate,
       mentorsessiontypename             AS SessionType,
       sms.SessionNote,
       sms.SessionDuration,
       s.Affiliation,
       s.i3ControlGroup,
       i3StudyGroupMember,
       MentorStatusName,
       --sm.assigneddate,
       o.officename
       --, os.Donor
       --( Select Top (1) Donor
       --  From Offices.Scholarships
       --  Where Offices.Scholarships.StudentID = s.StudentID and Offices.Scholarships.isdeleted = 0) As DonorName
        ,
       CASE
           WHEN sessionsourceid = 0 THEN 'STAR'
           WHEN sessionsourceid = 1 THEN 'MobileApp'
           WHEN sessionsourceid = 2 THEN 'MentorWebPortal'
           ELSE ''
           END                           AS SessionSource
        ,tmscte.TotalMentorSessions
        ,lmsdcte.lastsessiondate
        ,fmsdcte.firstsessiondate
        ,mncte.Mentors AS MatchedMentors
        , CASE
            --When madcte.AssignedDate > '2016-07-01' and fmsdcte.FirstSessionDate IS NULL --or madcte.AssignedDate > '2015-07-0' and (DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.AssignedDate, '1900-01-01')) + 1) > 30 Then DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0
			when madcte.AssignedDate between '2020-07-01' and '2020-09-14' and fmsdcte.FirstSessionDate is Null and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') >= madcte.DTU then 0
			when madcte.AssignedDate between '2020-07-01' and '2020-09-14' and fmsdcte.FirstSessionDate is Null and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') < madcte.DTU and madcte.DTU > '2020-10-15' and Round((DateDiff(day,'2020-10-15', IsNull( madcte.DTU, '1900-01-01')))/30.0,3) <7.5 then Round((DateDiff(day,'2020-10-15', IsNull( madcte.DTU, '1900-01-01')))/30.0,3)
			when madcte.AssignedDate between '2020-07-01' and '2020-09-14' and fmsdcte.FirstSessionDate is Null and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') < madcte.DTU and madcte.DTU > '2020-10-15' and Round((DateDiff(day,'2020-10-15', IsNull( madcte.DTU, '1900-01-01')))/30.0,3) >7.5 then 7.5
			when madcte.AssignedDate between '2020-07-01' and '2020-09-14' and fmsdcte.FirstSessionDate is Null and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') < madcte.DTU and madcte.DTU < '2020-10-15' then 0
			--*commented out for month cap*--when madcte.AssignedDate between '2016-07-01' and '2016-09-14' and fmsdcte.FirstSessionDate is not Null and fmsdcte.FirstSessionDate < '2016-10-15' then  Round((DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01')))/30.0,2)
			when madcte.AssignedDate between '2020-07-01' and '2020-09-14' and fmsdcte.FirstSessionDate is not Null and fmsdcte.FirstSessionDate > '2020-10-15' and Round((DateDiff(day,'2020-10-15',  IsNull( madcte.DTU, '1900-01-01')))/30.0,2) < 7.5 then  Round((DateDiff(day,'2020-10-15',  IsNull( madcte.DTU, '1900-01-01')))/30.0,2)
			when madcte.AssignedDate between '2020-07-01' and '2020-09-14' and fmsdcte.FirstSessionDate is not Null and fmsdcte.FirstSessionDate > '2020-10-15' and Round((DateDiff(day,'2020-10-15',  IsNull( madcte.DTU, '1900-01-01')))/30.0,2) > 7.5 then 7.5
			when madcte.AssignedDate >= '2020-09-15' and fmsdcte.FirstSessionDate is Null and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') >= madcte.DTU then 0
			when madcte.AssignedDate >= '2020-09-15' and fmsdcte.FirstSessionDate is Null and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') < madcte.DTU and Round(DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0,2) < 7.5 then Round(DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0,2)
			when madcte.AssignedDate >= '2020-09-15' and fmsdcte.FirstSessionDate is Null and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') < madcte.DTU and Round(DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0,2) > 7.5 then 7.5
			when madcte.AssignedDate >= '2020-09-15' and fmsdcte.FirstSessionDate > IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') and Round(DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0,2) < 7.5 then Round(DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0,2)
			when madcte.AssignedDate >= '2020-09-15' and fmsdcte.FirstSessionDate > IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') and Round(DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0,2) > 7.5 then 7.5
			when madcte.AssignedDate >= '2020-09-15' and fmsdcte.FirstSessionDate < IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') and Round((DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01')))/30.0,2) < 7.5 then Round((DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01')))/30.0,2)
			when madcte.AssignedDate >= '2020-09-15' and fmsdcte.FirstSessionDate < IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') and Round((DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01')))/30.0,2) > 7.5 then 7.5
			when madcte.AssignedDate < '2020-07-01' AND fmsdcte.FirstSessionDate is Null AND tmscte.TotalMentorSessions is Null and madcte.DTU > '2020-10-15' and Round(DateDiff(day,'2020-10-15', IsNull( madcte.DTU, '1900-01-01'))/30.0,2) <7.5 then Round(DateDiff(day,'2020-10-15', IsNull( madcte.DTU, '1900-01-01'))/30.0,2)
			when madcte.AssignedDate < '2020-07-01' AND fmsdcte.FirstSessionDate is Null AND tmscte.TotalMentorSessions is Null and madcte.DTU > '2020-10-15' and Round(DateDiff(day,'2020-10-15', IsNull( madcte.DTU, '1900-01-01'))/30.0,2) >7.5 then 7.5
			when madcte.AssignedDate < '2020-07-01' AND fmsdcte.FirstSessionDate is Null AND tmscte.TotalMentorSessions is Null and madcte.DTU < '2020-10-15' then 0
			--when madcte.AssignedDate > '2016-07-01' and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') > IsNull( madcte.DTU, '1900-01-01') then 0
			--when madcte.AssignedDate > '2016-07-01' and (DateDiff(DAY,IsNull(madcte.AssignedDate, '1900-02-01'),  IsNull(fmsdcte.FirstSessionDate, '1900-01-01')) + 1) > 30.0 then  DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0
			when madcte.AssignedDate < '2020-07-01'  and fmsdcte.FirstSessionDate > '2020-10-15' and Round(DateDiff(day,'2020-10-15', IsNull( madcte.DTU, '1900-01-01'))/30.0,2) <7.5 then  Round(DateDiff(day,'2020-10-15', IsNull( madcte.DTU, '1900-01-01'))/30.0,2)
			when madcte.AssignedDate < '2020-07-01'  and fmsdcte.FirstSessionDate > '2020-10-15' and Round(DateDiff(day,'2020-10-15', IsNull( madcte.DTU, '1900-01-01'))/30.0,2) >7.5 then 7.5
			when madcte.AssignedDate > fmsdcte.FirstSessionDate and Round((DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01')))/30.0,2) <7.5 then Round((DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01')))/30.0,2)
			when madcte.AssignedDate > fmsdcte.FirstSessionDate and Round((DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01')))/30.0,2) >7.5 then 7.5
			when madcte.AssignedDate < '2020-07-01' and (DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01')))/30.0 > 7.50 then 7.5
			when madcte.AssignedDate > '2020-07-01' and (DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01')))/30.0 > 7.50 then 7.5
			Else Round( (DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01'))) /30.0, 2 )
           END As NumberMonthsWithSessions
        , CASE 	when madcte.AssignedDate between '2020-07-01' and '2020-09-14' and fmsdcte.FirstSessionDate is Null and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') >= madcte.DTU then Round(Convert(decimal,(tmscte.TotalMentorSessions /1.0)),0)
            when madcte.AssignedDate between '2020-07-01' and '2020-09-14' and fmsdcte.FirstSessionDate is Null and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') < madcte.DTU and madcte.DTU > '2020-10-15' and Round((DateDiff(day,'2020-10-15',  IsNull( madcte.DTU, '1900-01-01'))/30.0),2) <7.5 then Round(Convert(decimal,(tmscte.TotalMentorSessions) / Round((DateDiff(day,'2020-10-15',  IsNull( madcte.DTU, '1900-01-01'))/30.0),2)),0)
            when madcte.AssignedDate between '2020-07-01' and '2020-09-14' and fmsdcte.FirstSessionDate is Null and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') < madcte.DTU and madcte.DTU > '2020-10-15' and Round((DateDiff(day,'2020-10-15',  IsNull( madcte.DTU, '1900-01-01'))/30.0),2) >7.5 then Round(Convert(decimal,(tmscte.TotalMentorSessions) / 7.5),2)
            when madcte.AssignedDate between '2020-07-01' and '2020-09-14' and fmsdcte.FirstSessionDate is Null and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') < madcte.DTU and madcte.DTU < '2020-10-15' then Round(Convert(decimal,(tmscte.TotalMentorSessions /1.0)),0)
            when madcte.AssignedDate between '2020-07-01' and '2020-09-14' and fmsdcte.FirstSessionDate is not Null and fmsdcte.FirstSessionDate<>madcte.DTU and fmsdcte.FirstSessionDate < '2020-10-15' and Round((DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0),2) <7.5 then Round(Convert(decimal,(tmscte.TotalMentorSessions) / Round((DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0),2)),0)
            when madcte.AssignedDate between '2020-07-01' and '2020-09-14' and fmsdcte.FirstSessionDate is not Null and fmsdcte.FirstSessionDate<>madcte.DTU and fmsdcte.FirstSessionDate < '2020-10-15' and Round((DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0),2) >7.5 then Round(Convert(decimal,(tmscte.TotalMentorSessions) / 7.5),2)
            when madcte.AssignedDate between '2020-07-01' and '2020-09-14' and fmsdcte.FirstSessionDate is not Null and madcte.DTU<>'2020-10-15' and fmsdcte.FirstSessionDate > '2020-10-15' and Round((DateDiff(day,'2020-10-15',  IsNull( madcte.DTU, '1900-01-01'))/30.0),2) <7.5 then Round(Convert(decimal,(tmscte.TotalMentorSessions) / Round((DateDiff(day,'2020-10-15',  IsNull( madcte.DTU, '1900-01-01'))/30.0),2)),0)
            when madcte.AssignedDate between '2020-07-01' and '2020-09-14' and fmsdcte.FirstSessionDate is not Null and madcte.DTU<>'2020-10-15' and fmsdcte.FirstSessionDate > '2020-10-15' and Round((DateDiff(day,'2020-10-15',  IsNull( madcte.DTU, '1900-01-01'))/30.0),2) >7.5 then Round(Convert(decimal,(tmscte.TotalMentorSessions) / 7.5),2)
            when fmsdcte.FirstSessionDate = madcte.DTU then Null
            when madcte.AssignedDate > '2020-09-14' and fmsdcte.FirstSessionDate is null and (DATEADD(month,1,madcte.AssignedDate)) = madcte.DTU then Null
            when madcte.AssignedDate > '2020-09-14' and fmsdcte.FirstSessionDate is Null and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') > madcte.DTU then Round(Convert(decimal,(tmscte.TotalMentorSessions /1.0)),0)
            when madcte.AssignedDate > '2020-09-14' and fmsdcte.FirstSessionDate is Null and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') <> madcte.DTU and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') < madcte.DTU and Round((DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0),2) <7.5 then Round(Convert(decimal,(tmscte.TotalMentorSessions) / Round((DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0),2)),0)
            when madcte.AssignedDate > '2020-09-14' and fmsdcte.FirstSessionDate is Null and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') <> madcte.DTU and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') < madcte.DTU and Round((DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0),2) >7.5 then Round(Convert(decimal,(tmscte.TotalMentorSessions) / 7.5),2)
            when madcte.AssignedDate > '2020-09-14' and fmsdcte.FirstSessionDate > IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') <> madcte.DTU  and Round((DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0),2) <7.5 then  Round(Convert(decimal,(tmscte.TotalMentorSessions) / Round((DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0),2)),0)
            when madcte.AssignedDate > '2020-09-14' and fmsdcte.FirstSessionDate > IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') and IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') <> madcte.DTU  and Round((DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0),2) >7.5 then  Round(Convert(decimal,(tmscte.TotalMentorSessions) / 7.5),2)
            when madcte.AssignedDate > '2020-09-14' and fmsdcte.FirstSessionDate < IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') and IsNull(fmsdcte.FirstSessionDate, '1900-02-01') <> madcte.DTU and  Round((DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0),2) <7.5 then Round(Convert(decimal,(tmscte.TotalMentorSessions) / Round((DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0),2)),0)
            when madcte.AssignedDate > '2020-09-14' and fmsdcte.FirstSessionDate < IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') and IsNull(fmsdcte.FirstSessionDate, '1900-02-01') <> madcte.DTU and  Round((DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0),2) >7.5 then Round(Convert(decimal,(tmscte.TotalMentorSessions) / 7.5),2)
            When madcte.AssignedDate > '2020-07-01' and fmsdcte.FirstSessionDate IS NULL and (DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0) <7.5 then  Round(Convert(decimal,(tmscte.TotalMentorSessions) / (DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0)),0)
            When madcte.AssignedDate > '2020-07-01' and fmsdcte.FirstSessionDate IS NULL and (DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0) >7.5 then  Round(Convert(decimal,(tmscte.TotalMentorSessions) / 7.5),2)
            ----when madcte.AssignedDate > '2016-07-01' and (DateDiff(DAY,IsNull(madcte.AssignedDate, '1900-02-01'),  IsNull(fmsdcte.FirstSessionDate, '1900-01-01')) + 1) > 30.0 then  Round(Convert(decimal,(tmscte.TotalMentorSessions) / (DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0)),0)
            When madcte.AssignedDate < '2020-07-01' and fmsdcte.FirstSessionDate > '2020-10-15' and madcte.DTU <>'2020-10-15' and Round((DateDiff(day,'2020-10-15',  IsNull( madcte.DTU, '1900-01-01'))/30.0),2) <7.5 then Floor(Convert(int,(tmscte.TotalMentorSessions) / Round((DateDiff(day,'2020-10-15',  IsNull( madcte.DTU, '1900-01-01'))/30.0),2)))
            When madcte.AssignedDate < '2020-07-01' and fmsdcte.FirstSessionDate > '2020-10-15' and madcte.DTU <>'2020-10-15' and Round((DateDiff(day,'2020-10-15',  IsNull( madcte.DTU, '1900-01-01'))/30.0),2) >7.5 then Floor(Convert(int,(tmscte.TotalMentorSessions) / 7.5))
            ----When (DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01')) + 1) <= 30.0 Then Floor(Convert(int,(tmscte.TotalMentorSessions /1.0)))
            ---- when fmsdcte.FirstSessionDate is not null and  IsNull(fmsdcte.FirstSessionDate, '1900-02-01') = IsNull( madcte.DTU, '1900-01-01') then 1
             ----when IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01') = IsNull( madcte.DTU, '1900-01-01') then 1
            when madcte.AssignedDate > fmsdcte.FirstSessionDate and fmsdcte.FirstSessionDate<>madcte.DTU and Round((DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0),2) <7.5 then Round(Convert(decimal,(tmscte.TotalMentorSessions) / Round((DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0),2)),0)
            when madcte.AssignedDate > fmsdcte.FirstSessionDate and fmsdcte.FirstSessionDate<>madcte.DTU and Round((DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0),2) >7.5 then Round(Convert(decimal,(tmscte.TotalMentorSessions)/7.5),2)
            when (DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01')))/30.0 = 0.0 Then Round(Convert(decimal,(tmscte.TotalMentorSessions /1.0)),0)
            ----when (DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01')))/30.0 = 0.0 Then Round(Convert(decimal,(tmscte.TotalMentorSessions /1.0)),0)
            when (DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01')))/30.0 > 7.5 then Floor(Convert(int,(tmscte.TotalMentorSessions/7.5)))
            ---when (DateDiff(DAY,IsNull(DATEADD(month,1,madcte.AssignedDate), '1900-01-01'),  IsNull( madcte.DTU, '1900-01-01')))/30.0 > 8.0 Then Round(Convert(decimal,(tmscte.TotalMentorSessions/8.0)),0)
            when (DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01')))/30.0 = 0.0 then (Convert(int,(tmscte.TotalMentorSessions/1.0)))
            ----floor(Convert(int,(tmscte.TotalMentorSessions) / (DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0)))
            Else floor(Convert(int,(tmscte.TotalMentorSessions) / Round((DateDiff(DAY,IsNull(fmsdcte.FirstSessionDate, '1900-02-01'),  IsNull( madcte.DTU, '1900-01-01'))/30.0),2)))
         End As AvgSessionsMonth
        ,madcte.AssignedDate
FROM Students.MentoringSessions AS sms
INNER JOIN Students.Students AS s ON s.StudentID = sms.StudentID
INNER JOIN Lookups.StudentStatuses AS ss ON s.StudentStatusID = ss.StudentStatusID
INNER JOIN Schools.Schools AS sch ON s.SchoolID = sch.SchoolID
INNER JOIN offices.offices o ON o.officeid = s.officeid
INNER JOIN Lookups.Counties AS c ON s.CountyID = c.CountyID
LEFT OUTER JOIN offices.Staff ST on s.AdvocateID = st.StaffID
--Left outer Join-- Offices.Scholarships os ON s.StudentID = os.StudentID
--LEFT OUTER JOIN Students.StudentMentors AS sm ON s.StudentID = sm.StudentID --AND (sm.UnassignedDate < '2017-08-01' OR sm.UnassignedDate IS NULL) --AND sm.MentorAssignmentTypeID = 1
INNER JOIN Mentors.Mentors AS m ON sms.MentorID = m.MentorID
LEFT JOIN lookups.mentorsessiontypes ON sms.sessiontypeid = mentorsessiontypes.mentorsessiontypeid
INNER JOIN Lookups.MentorStatuses ms ON m.MentorStatusID = ms.MentorStatusID
LEFT JOIN MatchedMentorNamesCte mncte ON mncte.StudentID = S.StudentID
LEFT JOIN totalMentorSessionsCte tmscte ON s.studentID=tmscte.studentID
LEFT JOIN LastMentorSessionDate lmsdcte ON s.studentid=lmsdcte.studentID
LEFT JOIN FirstMentorSessionDate fmsdcte ON s.studentid=fmsdcte.studentid
LEFT JOIN MentorAssignedDate madcte ON s.studentid=madcte.studentid
WHERE 1 = 1
  AND s.StudentStatusID IN (1, 3, 4, 5)
  AND s.IsDeleted = 0
  AND m.IsDeleted = 0
  AND sms.IsDeleted = 0

