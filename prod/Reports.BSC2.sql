WITH -- Common CTE for total active students for the time period (for mentor match rates, etc)
	 totalMentorSessionsCte (TotalMentorSessions, StudentID,IsTransfer) As
	(
		select t.Totalsessions
			,s.studentid
			,t.IsTransfer
			from students.students s
			left join reports.BSC_Dates t on t.Studentid = s.StudentID
			where s.StudentStatusID in (1,3,4,5)
	),

	-- CTE for last mentor/student session date
	LastMentorSessionDate (LastSessionDate, StudentID) As
	(
		select t.Lastsession
			,s.studentid
			from students.students s
			left join Reports.BSC_Dates t on t.Studentid = s.StudentID
			where s.StudentStatusID in (1,3,4,5)
	),

	---- CTE for last mentor/student session date
	FirstMentorSessionDate (FirstSessionDate, StudentID) As
	(
		Select t.Firstsession
			,s.studentid
			from students.students s
			left join Reports.BSC_Dates t on t.Studentid = s.StudentID
			where s.StudentStatusID in (1,3,4,5)

	),

	Dates (StartDate, EndDate, StudentID) as
	(
	/*Started with Tranfsers First and then regualr students */


		Select case when d.IsTransfer = 1 and d.Firstsession is null and d.TstartDates > d.EndDate then Null
					when d.IsTransfer = 1 and d.Firstsession is null and d.TstartDates < d.EndDate then d.TstartDates
					when d.IsTransfer = 1 and d.Firstsession > d.TstartDates then d.TstartDates
					when d.IsTransfer = 1 and d.Firstsession <= d.TstartDates then d.Firstsession
					when d.IsTransfer = 0 and d.ContractSignedDate < '2018-09-16' then d.TstartDates


				--when ss.ContractSignedDate < '2017-09-16' then Convert (date, '2017-10-15')
					when d.IsTransfer = 0 and d.ContractSignedDate >= '2018-09-16' and d.FirstSession is null and Convert (date, DATEADD(Day,30,d.ContractSignedDate)) >= d.EndDate then null
					when d.IsTransfer = 0 and d.ContractSignedDate >= '2018-09-16' and d.FirstSession is null and Convert (date, DATEADD(Day,30,d.ContractSignedDate)) < d.EndDate then Convert (date, DATEADD(Day,30,d.ContractSignedDate))
					when d.IsTransfer = 0 and d.ContractSignedDate >= '2018-09-16' and d.FirstSession < '2018-10-15' then Convert (date,'2018-10-15')
					--when ss.ContractSignedDate >= '2017-09-16' and fmsd.FirstSessionDate > '2017-10-15' then Convert (date,fmsd.FirstSessionDate) took out and split into 2 categories below -DR
					when d.IsTransfer = 0 and d.ContractSignedDate >= '2018-09-16' and d.FirstSession > Convert (date, DATEADD(Day,30,d.ContractSignedDate)) then Convert (date, DATEADD(Day,30,d.ContractSignedDate))
					when d.IsTransfer = 0 and d.ContractSignedDate >= '2018-09-16' and d.FirstSession <= Convert (date, DATEADD(Day,30,d.ContractSignedDate)) then Convert (date,d.FirstSession)


					else ''
				end as StartDate
		,d.EndDate
		,d.StudentID
		--,ss.OfficeID
		from reports.BSC_Dates d--students.Students ss
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
	MentorAssignedDate (AssignedDate, DTU, StudentID, OfficeID) As
	(
		Select MIN(sms.AssignedDate) As AssignedDate,
			Case when Convert (date, GETDATE()) > '2019-06-01'
		Then '2019-06-01'
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
	,
	Final (StudentId, TotalMonths, Average, Officeid, OfficeName) as


	(Select	ss.StudentID

			,tmcte.TotalMonths
			,case when convert(date, getdate()) < '2018-10-16' then null
					else round(convert(decimal,(tmscte.TotalMentorSessions/tmcte.TotalMonths)),3)
					end as 'AvgSession/Month'

			,ss.OfficeID
			,o.OfficeName
	from students.Students ss
	--left join Dates d on d.StudentID = ss.StudentID
	left join TotalMonths tmcte on ss.StudentID = tmcte.StudentID
	left join totalMentorSessionsCte tmscte on tmscte.StudentID = ss.StudentID
	left join offices.Offices o on o.OfficeID = ss.OfficeID
	--left join MentorNamesCte mncte on ss.StudentID = mncte.StudentID
	--INNER JOIN Schools.Schools SCH ON SCH.SchoolID = ss.SchoolID
	--left join FirstMentorSessionDate fmsdcte on ss.StudentID = fmsdcte.StudentID
	--left join LastMentorSessionDate lmsdcte on ss.StudentID = lmsdcte.StudentID
	--left join reports.BSC_Dates bd on bd.StudentID = ss.StudentID
--	left join lookups.Counties c on c.CountyID = ss.CountyID
	Where ss.StudentStatusID
				In (1, 3, 4, 5)

			and ss.IsDeleted = 0
			group by OfficeName, ss.StudentID,tmcte.TotalMonths, TotalMentorSessions, ss.OfficeID
    )
	,

	TMonths (OfficeId, TotalMts, OfficeName) as

    (Select Officeid, count(TotalMonths)as Totalmts, OfficeName
    from Final
    where TotalMonths is not null
    group by Officeid, OfficeName)

    ,taverage (OfficeId, Totalav, OfficeName) as

    (Select Officeid, count(Average)as Totalaverage, OfficeName
    from Final
    where Average >=2
    group by Officeid, OfficeName)


Select
		8 As DataPointNumber,
		'No. of Students averaging 2 sessions/month' as 'Metric', -- DataPointDescription
		--tss.CountyID,
		Tmon.OfficeName,
		IsNull(sum(tav.Totalav), 0)  As KPI, --ValueMatch
		IsNull(sum(Tmon.TotalMts), 0)  As Total, -- Total
		Convert(Int, Ceiling((IsNull(sum(tav.Totalav), 0) / Cast(Tmon.TotalMts As Decimal)) * 100)) As Result, -- percent
            CASE
            when Convert(Int, Ceiling((IsNull(sum(tav.Totalav), 0) / Cast(Tmon.TotalMts As Decimal)) * 100)) between 85 and 100 then 20
            when Convert(Int, Ceiling((IsNull(sum(tav.Totalav), 0) / Cast(Tmon.TotalMts As Decimal)) * 100)) between 70 and 84 then 9
            when Convert(Int, Ceiling((IsNull(sum(tav.Totalav), 0) / Cast(Tmon.TotalMts As Decimal)) * 100)) < 70 then 0
            else ''
		end as Score,
		'' as Comments,
		Tmon.OfficeID
	From TMonths Tmon
		left join taverage tav  on Tmon.OfficeID = tav.OfficeID
	group by Tmon.OfficeName, tmon.OfficeID, Tmon.TotalMts
