SELECT      
	s.studentid,
	'XXX-XX-'+right(CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedSSN)),4) as SSN,
	s.LastName, 
	s.FirstName, 
	CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthdate)) AS BirthDate, 
	cty.CountyName,  
	s.Gender,  
	s.AddressID, 
	s.HomePhoneNumber,
	s.WorkPhoneNumber,
	s.MobilePhoneNumber, 
	s.EmailAddress, 
	sch.SchoolName, 
	s.CurrentGradeLevelID, 
	s.EntryGradeLevelID
	,	case when sa.ApplicationCompletionDate is null then 'Not Required'
		Else convert(varchar,sa.IncomeEligibilityDocumentsSubmited) 
	end as IncomeEligibilityDocumentsSubmited
	,	case when sa.ApplicationCompletionDate is null then 'Not Required'
		Else convert(varchar,sa.FinalReportCardSubmited)
	end as FinalReportCardSubmited
	,case when sa.ApplicationCompletionDate is null then 'Not Required'
		Else convert(varchar,sa.InterviewsConducted)
		end as InterviewsConducted
	,case when sa.ApplicationCompletionDate is null then 'Not Required'
		Else convert(varchar,sa.CheckTranscripts)
		end as CheckTranscripts
	,case when sa.ApplicationCompletionDate is null then 'Not Required'
		Else convert(varchar,sa.FinanciallyQualified)
		end as FinanciallyQualified
	,case when sa.ApplicationCompletionDate is null then 'Not Required'
		Else convert(varchar,sa.ReferenceFormSubmitted)
		end as ReferenceFormSubmitted			
	,case when sa.GPA is null then s.EntryGPA 
		  when sa.GPA = 0 then s.EntryGPA
		  else sa.GPA 
	 end as EntryGPA
	,case when sa.ApplicationCompletionDate is null then 'Not Required'
		Else convert(varchar,sa.RiskFactorScore)
	end as RiskFactorScore
	, case when sa.PriorityType is null then s.PriorityType else sa.PriorityType end as StudentType, 
	ctt.ContractTypeName as ContractType,
	r.RaceName as Race, 
	s.IsHispanic, 
	os.FirstName+' '+os.LastName as  AdvocateName, 
	s.ContractSignedDate, 
	fs.FamilySituationName as FamilySituation, 
	s.FirstGenerationCollegeStudent,
	CASE 
		WHEN s.CurrentGradeLevelID = 12 THEN coll.collegename
		ELSE 'Not Required' 
	END AS CollegePrepCollegeChoice,
	CASE 
		WHEN initialmentor.studentid IS NOT NULL THEN 'True'
		ELSE ''
	END AS InitialMentorMatch,
    (SELECT TOP(1) sc.ContactName FROM Students.Contacts AS sc			WHERE (sc.StudentID = s.StudentID) and sc.IsDeleted = 0) AS Guardian,
	(SELECT TOP(1) sc.EmailAddress FROM  Students.Contacts AS sc		WHERE (sc.StudentID = s.StudentID) and sc.IsDeleted = 0)	AS GuardianEmail,
	(SELECT TOP(1) case 
						when sc.ContactCellPhone is null or sc.ContactCellPhone = '' then sc.ContactHomePhone
						when  sc.ContactHomePhone is null or sc.ContactHomePhone = '' then sc.ContactWorkPhone
						else sc.ContactCellPhone
					end as Phone
				FROM	Students.Contacts AS sc
				WHERE   (sc.StudentID = s.StudentID) and sc.IsDeleted = 0) AS GuardianPhone,
	(SELECT     TOP (1) sc.AddressID FROM Students.Contacts AS sc WHERE      (sc.StudentID = s.StudentID) and sc.IsDeleted = 0) AS GuardianAddress,				
	s.OfficeID						 
FROM	Students.Students AS s 
LEFT OUTER JOIN Lookups.StudentStatuses ON s.StudentStatusID = Lookups.StudentStatuses.StudentStatusID 
LEFT OUTER JOIN Students.Applications AS sa ON s.StudentID = sa.StudentID 
INNER JOIN Lookups.Counties AS cty ON cty.CountyID = s.CountyID
LEFT JOIN lookups.FamilySituations fs on fs.FamilySituationID = s.FamilySituationID
LEFT JOIN [Lookups].[Races] r on s.RaceID = r.raceid
LEFT JOIN offices.Staff os on os.StaffID = s.AdvocateID
LEFT JOIN Schools.Schools sch on sch.SchoolID = s.SchoolID
LEFT JOIN lookups.ContractTypes ctt on ctt.ContractTypeID = s.ContractTypeID
LEFT JOIN Lookups.Colleges AS coll ON coll.CollegeID = s.finalcollegeid
LEFT JOIN (SELECT DISTINCT studentid FROM  Students.studentmentors WHERE isdeleted = 0) initialmentor ON s.studentid=initialmentor.studentid
WHERE			
	s.StudentStatusID In (1, 3, 4, 5) -- All active except "On Hold" 
	AND s.IsDeleted = 0
	And (
		CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedSSN)) IS NULL
		or s.FirstName is null
		or s.LastName is null
		OR  CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthdate)) IS NULL
		or s.CountyID is null
		or s.Gender is null
		or s.AddressID is null
		Or (
			s.HomePhoneNumber Is Null 
			AND s.WorkPhoneNumber Is Null 
			AND s.MobilePhoneNumber Is Null
		) 
		or s.EmailAddress is null
		or s.SchoolID  is null
		or s.CurrentGradeLevelID is null
		or s.EntryGradeLevelID is null
		or (sa.IncomeEligibilityDocumentsSubmited = 0 and sa.ApplicationCompletionDate is not null)
		or (sa.FinalReportCardSubmited = 0 and sa.ApplicationCompletionDate is not null)
		or (sa.InterviewsConducted = 0 and sa.ApplicationCompletionDate is not null)
		or (sa.CheckTranscripts = 0 and sa.ApplicationCompletionDate is not null)
		or (sa.FinanciallyQualified = 0 and sa.ApplicationCompletionDate is not null)
		or (sa.ReferenceFormSubmitted = 0 and sa.ApplicationCompletionDate is not null)
		or ((s.EntryGPA is null and sa.GPA is null) or (s.EntryGPA = 0 and sa.GPA = 0) or (s.EntryGPA IS NULL and sa.GPA = 0) or (s.EntryGPA = 0 and sa.GPA IS NULL))
		or (sa.RiskFactorScore is null and sa.ApplicationCompletionDate is not null)
		or (s.PriorityType is null and sa.PriorityType is null)
		or s.ContractTypeID is null
		or s.RaceID is null
		or s.IsHispanic is null
		or s.AdvocateID is null
		Or s.ContractSignedDate Is Null
		or s.FamilySituationID is null
		or s.FirstGenerationCollegeStudent is null
		OR (s.currentgradelevelid = 12 AND coll.collegename IS NULL)     --comment for midyear, uncomment for end of year
		OR (initialmentor.studentid IS NULL AND datediff(day,s.contractsigneddate, getdate()) > 30 ) 
		or  Not Exists (
			Select Top 1 
				ContactID
			From Students.Contacts sc
			Where s.StudentID = StudentID and sc.IsDeleted = 0)
		Or Not Exists (
			Select Top 1 
				EmailAddress
			From Students.Contacts sc
			Where s.StudentID = StudentID and sc.IsDeleted = 0)
		Or  Exists (
			Select Top 1 
				ContactID
			From Students.Contacts sc
			Where s.StudentID = StudentID and  (sc.ContactCellPhone is null and sc.ContactHomePhone is null and sc.ContactWorkPhone is null) and sc.IsDeleted = 0)

		)
