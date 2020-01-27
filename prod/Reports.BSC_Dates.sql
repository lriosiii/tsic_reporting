With tDate_CTE (tdate,xtdate, Studentid)--toffice)
AS
(Select Distinct
(	SELECT TOP (1) t.TransferDate
			From Students.SchoolTransferHistory t
			--left join Students.Students s on s.StudentID = t.StudentID 
			Where t.StudentID = s.StudentID
			and s.IsDeleted = 0  and t.IsDeleted = 0
			and s.OfficeID <> t.OfficeID
			and t.TransferDate between '2019-07-01' and '2020-06-30'
			ORDER BY TransferDate desc
	   )  as tdate,
(	SELECT TOP (1) t.TransferDate
			From Students.SchoolTransferHistory t
			--left join Students.Students s on s.StudentID = t.StudentID 
			Where t.StudentID = s.StudentID
			and s.IsDeleted = 0  and t.IsDeleted = 0
			and s.OfficeID <> t.OfficeID
			ORDER BY TransferDate desc
	   )  as xtdate
	   ,s.StudentID
	   
	   --,t.OfficeID

	   FROM [TSIC_Prod].[Students].[Students] s
  Left outer join Offices.Offices o on s.OfficeID = o.OfficeID
  inner join students.SchoolTransferHistory t on s.StudentID = t.StudentID
  ),

  TotalSessions (Totalsessions, studentid) as
	(select case when t.tdate is not null then (Select Count(sms.StudentID)
				From Students.MentoringSessions sms
				--left join reports.BSC_Dates bscd on bscd.StudentID = sms.StudentID
				 where sms.SessionDate >= t.tdate and sms.StudentID = s.StudentID
				 And sms.IsDeleted = 0
				And sms.SessionDuration > 0)
			 when t.tdate is null then (Select Count(sms.StudentID)
				From Students.MentoringSessions sms
				--left join reports.BSC_Dates bscd on bscd.StudentID = sms.StudentID
				 where  sms.StudentID = s.StudentID and sms.SessionDate Between '2019-07-01' and '2020-06-30'
				And sms.IsDeleted = 0
				And sms.SessionDuration > 0)
			end as TotalSessions
			,s.studentid
			from students.students s
			left join tDate_CTE t on t.Studentid = s.StudentID
			where s.StudentStatusID in (1,3,4,5)
			),

	LastSession (Lastsession, studentid) as
	(select case when t.tdate is not null then (Select max(sms.SessionDate)
				From Students.MentoringSessions sms
				--left join reports.BSC_Dates bscd on bscd.StudentID = sms.StudentID
				 where sms.SessionDate >= t.tdate and sms.StudentID = s.StudentID
				 And sms.IsDeleted = 0
				And sms.SessionDuration > 0)
			 when t.tdate is null then (Select max(sms.SessionDate)
				From Students.MentoringSessions sms
				--left join reports.BSC_Dates bscd on bscd.StudentID = sms.StudentID
				 where  sms.StudentID = s.StudentID and sms.SessionDate Between '2019-07-01' and '2020-06-30'
				And sms.IsDeleted = 0
				And sms.SessionDuration > 0)
			end as LastSessionDate
			,s.studentid
			from students.students s
			left join tDate_CTE t on t.Studentid = s.StudentID
			where s.StudentStatusID in (1,3,4,5)
			),

FirstSession (Firstsession, studentid) as
	(Select case when t.tdate is not null then (Select min(sms.SessionDate)
				From Students.MentoringSessions sms
				--left join reports.BSC_Dates bscd on bscd.StudentID = sms.StudentID
				 where sms.SessionDate >= t.tdate and sms.StudentID = s.StudentID
				 And sms.IsDeleted = 0
				And sms.SessionDuration > 0)
			 when t.tdate is null then (Select min(sms.SessionDate)
				From Students.MentoringSessions sms
				--left join reports.BSC_Dates bscd on bscd.StudentID = sms.StudentID
				 where  sms.StudentID = s.StudentID and sms.SessionDate Between '2019-07-01' and '2020-06-30'
				And sms.IsDeleted = 0
				And sms.SessionDuration > 0)
			end as FirstSessionDate
			,s.studentid
			from students.students s
			left join tDate_CTE t on t.Studentid = s.StudentID
			where s.StudentStatusID in (1,3,4,5)
			)

  Select
	s.StudentID
	,s.ContractSignedDate
	,t.tdate
    ,t.xtdate
	,case when t.tdate is not Null then Convert (date, DATEADD(Day,30,t.tdate))
		when s.ContractSignedDate < '2019-09-16' then Convert (date, '2019-10-15')
		end as TstartDates
	,case when t.tdate is not null then 1
		else 0
		end as IsTransfer
	,case when t.xtdate is not null then 1
		else 0
		end as xIsTransfer
	,case when t.tdate is not Null then t.tdate
		when t.tdate is null then s.ContractSignedDate
		end as MMCSCDate

	,Case when Convert (date, GETDATE()) > '2020-06-01' Then '2020-06-01'
	Else 
	CONVERT(date, GetDate())
	End As EndDate
	,ts.Totalsessions
	,fs.Firstsession
	,ls.Lastsession

--	,case when t.tdate is not null then (Select Count(sms.StudentID)
--				From Students.MentoringSessions sms
--				--left join reports.BSC_Dates bscd on bscd.StudentID = sms.StudentID
--				 where sms.SessionDate >= t.tdate and sms.StudentID = s.StudentID
--				 And sms.IsDeleted = 0
--				And sms.SessionDuration > 0)
--			 when t.tdate is null then (Select Count(sms.StudentID)
--				From Students.MentoringSessions sms
--				--left join reports.BSC_Dates bscd on bscd.StudentID = sms.StudentID
--				 where  sms.StudentID = s.StudentID and sms.SessionDate Between '2017-07-01' AND '2018-06-30'
--				And sms.IsDeleted = 0
--				And sms.SessionDuration > 0)
--			end as TotalSessions

--,case when t.tdate is not null then (Select max(sms.SessionDate)
--				From Students.MentoringSessions sms
--				--left join reports.BSC_Dates bscd on bscd.StudentID = sms.StudentID
--				 where sms.SessionDate >= t.tdate and sms.StudentID = s.StudentID
--				 And sms.IsDeleted = 0
--				And sms.SessionDuration > 0)
--			 when t.tdate is null then (Select max(sms.SessionDate)
--				From Students.MentoringSessions sms
--				--left join reports.BSC_Dates bscd on bscd.StudentID = sms.StudentID
--				 where  sms.StudentID = s.StudentID and sms.SessionDate Between '2017-07-01' AND '2018-06-30'
--				And sms.IsDeleted = 0
--				And sms.SessionDuration > 0)
--			end as LastSessionDate


--,case when t.tdate is not null then (Select min(sms.SessionDate)
--				From Students.MentoringSessions sms
--				--left join reports.BSC_Dates bscd on bscd.StudentID = sms.StudentID
--				 where sms.SessionDate >= t.tdate and sms.StudentID = s.StudentID
--				 And sms.IsDeleted = 0
--				And sms.SessionDuration > 0)
--			 when t.tdate is null then (Select min(sms.SessionDate)
--				From Students.MentoringSessions sms
--				--left join reports.BSC_Dates bscd on bscd.StudentID = sms.StudentID
--				 where  sms.StudentID = s.StudentID and sms.SessionDate Between '2017-07-01' AND '2018-06-30'
--				And sms.IsDeleted = 0
--				And sms.SessionDuration > 0)
--			end as FirstSessionDate

From students.Students s
left join tDate_CTE t on t.Studentid = s.StudentID
left join TotalSessions ts on ts.studentid = s.StudentID
left join FirstSession fs on fs.studentid = s.StudentID
left join LastSession ls on ls.studentid = s.StudentID
where s.StudentStatusID in (1,3,4,5) and s.IsDeleted = 0--and s.OfficeID = 6
