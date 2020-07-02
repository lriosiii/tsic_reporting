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
            In (1, 3, 4, 5) 
			And sms.SessionDate > DateAdd(yy, -2, GetDate())
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
				In (1, 3, 4, 5)
			And sms.IsDeleted = 0
			And sms.SessionDuration > 0
			And sms.SessionDate > DateAdd(yy, -2, GetDate())
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
				In (1, 3, 4, 5)
			And sms.IsDeleted = 0
			And sms.SessionDuration > 0
			And sms.SessionDate > DateAdd(yy, -2, GetDate())
			And sms.MentorID IN
			(Select MentorID
			 FROM Students.StudentMentors
			 Where StudentID = ss.StudentID
			 And (UnassignedDate IS NULL Or UnassignedDate = '')
			 AND MentorAssignmentTypeID = 1)
		Group By ss.StudentID, ss.OfficeID
	),

	-- CTE for mentor/student assigned date
	MentorAssignedDate (AssignedDate, DTU, StudentID, OfficeID) As
	(
		Select MIN(sms.AssignedDate) As AssignedDate,
			Case when Convert (date, GETDATE()) > '2020-06-01'
			Then '2020-06-01'
			Else
			CONVERT(date, GetDate())
		End As DateTU
			,ss.StudentID,
			ss.OfficeID
		From Students.StudentMentors sms
			Join Students.Students ss
				On ss.StudentID = sms.StudentID
		Where ss.StudentStatusID
				In (1, 3, 4, 5) 
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
				AND SMS.AssignedDate >= '2019-07-01'
				AND (SMS.UnassignedDate IS NULL)
				AND (SMS.MentorAssignmentTypeID = 1)
            For XML PATH ('')) [Mentors],


			(Select ST1.EmailAddress + '  ' AS [text()]
                From Mentors.Mentors ST1
                Left Outer Join Students.StudentMentors SMS ON ST1.MentorID = SMS.MentorID
                Where SMS.StudentID = ST2.StudentID
                    --AND (SMS.UnassignedDate > '2013-08-01' OR SMS.UnassignedDate IS NULL)
                    AND SMS.AssignedDate >= '2019-07-01'
                    AND (SMS.UnassignedDate IS NULL)
                    AND (SMS.MentorAssignmentTypeID = 1)
                For XML PATH ('')
			) [Mentorsemails]
     From Students.Students ST2) [Main]
	),
      Dates (StartDate, EndDate, StudentID) as
         (
             /*Started with Tranfsers and then regular students */
             Select case
                        WHEN d.IsTransfer = 1 and d.Firstsession is null and d.TstartDates > d.EndDate then Null
                        WHEN d.IsTransfer = 1 and d.Firstsession is null and d.TstartDates < d.EndDate
                            then d.TstartDates
                        WHEN d.istransfer = 1 and d.tdate < '2019-09-16' THEN '2019-10-15'
                        WHEN d.istransfer = 1 and d.tdate > '2019-09-15' AND
                             Convert(date, DATEADD(Day, 30, d.tdate)) <= d.firstsession
                            THEN Convert(date, DATEADD(Day, 30, d.tdate))
                        WHEN d.istransfer = 1 and d.tdate > '2019-09-15' AND
                             Convert(date, DATEADD(Day, 30, d.tdate)) > d.firstsession AND
                             d.firstsession <= '2019-10-15' THEN '2019-10-15'
                        WHEN d.istransfer = 1 and d.tdate > '2019-09-15' AND
                             Convert(date, DATEADD(Day, 30, d.tdate)) > d.firstsession THEN d.firstsession
                 --when ss.ContractSignedDate < '2017-09-16' then Convert (date, '2017-10-15')
                        when d.IsTransfer = 0 and d.ContractSignedDate < '2019-09-16' then d.TstartDates
                        when d.IsTransfer = 0 and d.ContractSignedDate >= '2019-09-16' and d.FirstSession is null and
                             Convert(date, DATEADD(Day, 30, d.ContractSignedDate)) >= d.EndDate then null
                        when d.IsTransfer = 0 and d.ContractSignedDate >= '2019-09-16' and d.FirstSession is null and
                             Convert(date, DATEADD(Day, 30, d.ContractSignedDate)) < d.EndDate
                            then Convert(date, DATEADD(Day, 30, d.ContractSignedDate))
                        when d.IsTransfer = 0 and d.ContractSignedDate >= '2019-09-16' and d.FirstSession < '2019-10-15'
                            then Convert(date, '2019-10-15')
                 --when ss.ContractSignedDate >= '2017-09-16' and fmsd.FirstSessionDate > '2017-10-15' then Convert (date,fmsd.FirstSessionDate) took out and split into 2 categories below -DR
                        when d.IsTransfer = 0 and d.ContractSignedDate >= '2019-09-16' and
                             d.FirstSession > Convert(date, DATEADD(Day, 30, d.ContractSignedDate))
                            then Convert(date, DATEADD(Day, 30, d.ContractSignedDate))
                        when d.IsTransfer = 0 and d.ContractSignedDate >= '2019-09-16' and
                             d.FirstSession <= Convert(date, DATEADD(Day, 30, d.ContractSignedDate))
                            then Convert(date, d.FirstSession)
                        else ''
                 end as StartDate
                  , d.EndDate
                  , d.StudentID
             from reports.BSC_Dates2 d--students.Students ss
             --left join FirstMentorSessionDate fmsd on d.StudentID = fmsd.StudentID
             --Where ss.StudentStatusID
             --		In (1, 3, 4, 5)
             --and ss.IsDeleted = 0
         )
     , TotalMonths (TotalMonths, StudentID, OfficeID) as
         (
             Select
                    CASE
                    WHEN DATEDIFF(DAY, d.StartDate, d.EndDate) <= 0 THEN NULL
                    WHEN Round((DATEDIFF(DAY, d.StartDate, d.EndDate)) / 30.0, 2) > 7.50 THEN 7.50
                    ELSE Round((DATEDIFF(DAY, d.StartDate, d.EndDate)) / 30.0, 2)
                 END AS TotalMonths
                  , ss.StudentID
                  , ss.OfficeID
             FROM Students.Students ss
             LEFT JOIN Dates d on ss.StudentID = d.StudentID
             WHERE ss.StudentStatusID IN (1, 3, 4, 5)
               AND ss.IsDeleted = 0
         )

SELECT  DISTINCT
    s.StudentID,
    o.OfficeName,
    s.FirstName AS MenteeFirstName,
    s.MiddleName AS MenteeMiddleName,
    s.LastName AS MenteeLastName,
    s.ContractSignedDate,
    mncte.Mentors AS MatchedMentors,
    sch.SchoolName,
    tmscte.TotalMentorSessions,
    lmsdcte.lastsessiondate,
    fmsdcte.firstsessiondate,
  	s.StudentStatusID,
  	s.OfficeID,
  	s.CurrentGradeLevelID,
  	ss.StudentStatusName,
	c.CountyName,
    madcte.AssignedDate
    ,tmcte.totalmonths As NumberMonthsWithSessions
    ,   CASE
        WHEN convert(date, getdate()) < '2019-10-16' THEN NULL
        ELSE floor(tmscte.TotalMentorSessions / tmcte.TotalMonths)
     END AS AvgSessionsMonth

FROM         Students.Students AS s
INNER JOIN Lookups.StudentStatuses AS ss ON s.StudentStatusID = ss.StudentStatusID
INNER JOIN Offices.Offices o ON s.OfficeID = o.OfficeID
Inner JOIN Schools.Schools AS sch ON s.SchoolID = sch.SchoolID
INNER JOIN Lookups.Counties AS c ON s.CountyID = c.CountyID
LEFT JOIN MatchedMentorNamesCte mncte ON mncte.StudentID = S.StudentID
LEFT JOIN totalMentorSessionsCte tmscte ON s.studentID=tmscte.studentID
LEFT JOIN LastMentorSessionDate lmsdcte ON s.studentid=lmsdcte.studentID
LEFT JOIN FirstMentorSessionDate fmsdcte ON s.studentid=fmsdcte.studentid
LEFT JOIN MentorAssignedDate madcte ON s.studentid=madcte.studentid
LEFT JOIN TotalMonths tmcte ON s.studentid=tmcte.StudentID
WHERE s.StudentStatusID IN (1,3,4,5)
	AND s.IsDeleted = 0
