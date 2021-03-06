WITH -- Common CTE for total active students for the time period (for mentor match rates, etc)
	totalMentorSessionsCte (TotalMentorSessions, StudentID, IsTransfer, FirstSessionDate, LastSessionDate) As
	(
		select t.Totalsessions
			,s.studentid
			,t.IsTransfer
			,t.Firstsession
			,t.Lastsession
			from students.students s
			left join reports.BSC_Dates2 t on t.Studentid = s.StudentID
			where s.StudentStatusID in (1,3,4,5)
	),

	---- CTE for last mentor/student session date
	--LastMentorSessionDate (LastSessionDate, StudentID) As
	--(
	--	select t.Lastsession
	--		,s.studentid
	--		from students.students s
	--		left join Reports.BSC_Dates2 t on t.Studentid = s.StudentID
	--		where s.StudentStatusID in (1,3,4,5)
	--),

	------ CTE for last mentor/student session date
	--FirstMentorSessionDate (FirstSessionDate, StudentID) As
	--(
	--	Select t.Firstsession
	--		,s.studentid
	--		from students.students s
	--		left join Reports.BSC_Dates2 t on t.Studentid = s.StudentID
	--		where s.StudentStatusID in (1,3,4,5)
			
	--),

	Dates (StartDate, EndDate, StudentID) as
	(
	/*Started with Tranfsers First and then regular students */


		Select case when d.IsTransfer = 1 and d.Firstsession is null and d.TstartDates > d.EndDate then Null
					when d.IsTransfer = 1 and d.Firstsession is null and d.TstartDates < d.EndDate then d.TstartDates
					WHEN d.istransfer = 1 and d.tdate < dbo.Sep16() THEN dbo.Oct15()
					WHEN d.istransfer = 1 and d.tdate > dbo.Oct15() AND Convert(date,DATEADD(Day,30,d.tdate)) <= d.firstsession THEN Convert(date,DATEADD(Day,30,d.tdate))
					WHEN d.istransfer = 1 and d.tdate > dbo.Oct15() AND Convert(date,DATEADD(Day,30,d.tdate)) > d.firstsession AND d.firstsession <= dbo.Oct15() THEN dbo.Oct15()
					WHEN d.istransfer = 1 and d.tdate > dbo.Oct15() AND Convert(date,DATEADD(Day,30,d.tdate)) > d.firstsession THEN d.firstsession

				    --when ss.ContractSignedDate < '2017-09-16' then Convert (date, '2017-10-15')
				    when d.IsTransfer = 0 and d.ContractSignedDate < dbo.Sep16() then d.TstartDates
					when d.IsTransfer = 0 and d.ContractSignedDate >= dbo.Sep16() and d.FirstSession is null and Convert (date, DATEADD(Day,30,d.ContractSignedDate)) >= d.EndDate then null
					when d.IsTransfer = 0 and d.ContractSignedDate >= dbo.Sep16() and d.FirstSession is null and Convert (date, DATEADD(Day,30,d.ContractSignedDate)) < d.EndDate then Convert (date, DATEADD(Day,30,d.ContractSignedDate))
					when d.IsTransfer = 0 and d.ContractSignedDate >= dbo.Sep16() and d.FirstSession < dbo.Oct15() then Convert (date,dbo.Oct15())
					--when ss.ContractSignedDate >= '2017-09-16' and fmsd.FirstSessionDate > '2017-10-15' then Convert (date,fmsd.FirstSessionDate) took out and split into 2 categories below -DR
					when d.IsTransfer = 0 and d.ContractSignedDate >= dbo.Sep16() and d.FirstSession > Convert (date, DATEADD(Day,30,d.ContractSignedDate)) then Convert (date, DATEADD(Day,30,d.ContractSignedDate))
					when d.IsTransfer = 0 and d.ContractSignedDate >= dbo.Sep16() and d.FirstSession <= Convert (date, DATEADD(Day,30,d.ContractSignedDate)) then Convert (date,d.FirstSession)


					else ''
				end as StartDate
		,d.EndDate
		,d.StudentID
		--,ss.OfficeID
		from reports.BSC_Dates2 d--students.Students ss
		--left join FirstMentorSessionDate fmsd on d.StudentID = fmsd.StudentID
		--Where ss.StudentStatusID
		--		In (1, 3, 4, 5)
			--and ss.IsDeleted = 0
		),

	TotalMonths	(TotalMonths, StudentID, OfficeID) as
	(
		Select case when DATEDIFF(DAY,d.StartDate, d.EndDate) <=0 then null
					when Round((DATEDIFF(DAY,d.StartDate, d.EndDate)) /30.0,2) >7.50 then 7.50
					else Round((DATEDIFF(DAY,d.StartDate, d.EndDate)) /30.0,2)

		end as TotalMonths
		,ss.StudentID
		,ss.OfficeID
		from Students.Students ss
		left join Dates d on ss.StudentID = d.StudentID
		Where ss.StudentStatusID
				In (1, 3, 4, 5)
			and ss.IsDeleted = 0

	),

	-- CTE for mentor/student assigned date
	MentorAssignedDate (AssignedDate, StudentID, OfficeID) As
	(
		Select MIN(sms.AssignedDate) As AssignedDate,
		--Case when Convert (date, GETDATE()) > '2020-06-01'
		--Then '2020-06-01'
		----Else
		--CONVERT(date, GetDate())
		--End As DateTU
			ss.StudentID,
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
	),

	-- CTE for mentor names
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
	)

	Select	ss.StudentID
			,ss.FirstName as StudentFirstName
			,ss.LastName as StudentLastName
			,ss.LastName +', '+ ss.FirstName as StudentFullName
			,ss.ContractSignedDate
			,mncte.Mentors
			,sch.SchoolName
			,ss.CurrentGradeLevelID
			--,d.StartDate
			--,d.EndDate
			--,bd.tdate as TransferDate
			,tmscte.TotalMentorSessions
			,tmscte.FirstSessionDate
			,tmscte.LastSessionDate
			,tmcte.TotalMonths
			,case when convert(date, getdate()) < '2019-10-16' then null
					else floor(tmscte.TotalMentorSessions/tmcte.TotalMonths)
					end as 'AvgSession/Month'
		,case when tmscte.IsTransfer = 1 then 'Yes' else 'No' end as IsTransfer
			,ss.OfficeID
			,c.CountyName
	from students.Students ss
	--left join Dates d on d.StudentID = ss.StudentID
	left join TotalMonths tmcte on ss.StudentID = tmcte.StudentID
	left join totalMentorSessionsCte tmscte on tmscte.StudentID = ss.StudentID
	left join MentorNamesCte mncte on ss.StudentID = mncte.StudentID
	INNER JOIN Schools.Schools SCH ON SCH.SchoolID = ss.SchoolID
	left join FirstMentorSessionDate fmsdcte on ss.StudentID = fmsdcte.StudentID
	left join LastMentorSessionDate lmsdcte on ss.StudentID = lmsdcte.StudentID
	--left join reports.BSC_Dates bd on bd.StudentID = ss.StudentID
	left join lookups.Counties c on c.CountyID = ss.CountyID
	Where ss.StudentStatusID
				In (1, 3, 4, 5)
				 --and ss.StudentStatusID = 3
				 --and ss.OfficeID =1

			and ss.IsDeleted = 0
	--		and CountyName = 'Alachua'
	--order by [AvgSession/Month]
