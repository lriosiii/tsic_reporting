SELECT
      o.OfficeName
	  ,s.StudentID
	  ,sts.StudentStatusName
	  ,ct.CountyName
	  ,s.CurrentGradeLevelID
	  , case when s.WfiEligible = 1 then 'Yes'
		else 'No'
		end as 'WorkforceStudent'
		, case when rbd.xIsTransfer = 1 then 'Yes'
		else 'No'
		end as TransferStudent
	  ,s.LastName
	  ,s.FirstName
      ,s.LastName + ', '+ s.FirstName as StudentFullName

      ,[ScholarshipOwner]
      ,[ContractNumber]
	  ,Donor
      ,[PurchaseDate]
      ,s.Affiliation
	  ,cnt.ContractTypeName
      ,[HoursAvail]
	  ,s.ContractSignedDate
	  ,s.GraduationYear

      --,[OriginalPey]
	  ,s.OfficeID

	  --,ss.IsDeleted
  FROM [TSIC_Prod].[Students].Students s
  join Offices.Offices o on s.OfficeID = o.OfficeID
  left join Offices.Scholarships ss on ss.StudentID = s.StudentID and ss.IsDeleted=0
  left join lookups.StudentStatuses sts on s.StudentStatusID = sts.StudentStatusID
  left join lookups.ContractTypes cnt on cnt.ContractTypeID = s.ContractTypeID
  left join lookups.Counties ct on ct.CountyID = s.CountyID
  left join reports.BSC_Dates rbd on rbd.StudentID = s.StudentID
  where  s.IsDeleted = 0 and s.StudentStatusID in (1,3,4,5) and (ss.ContractNumber is null or ss.HoursAvail = 0) AND s.wfieligible = 0 AND ISNULL(s.affiliation, '') NOT LIKE '%RSS%' AND rbd.xIsTransfer = 0
