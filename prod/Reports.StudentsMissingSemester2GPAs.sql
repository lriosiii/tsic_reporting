SELECT     S.FirstName, S.MiddleName, S.LastName, S.LastName + ', ' + S.FirstName AS StudentFullName, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedSSN)) AS SSN, CONVERT(varchar, DecryptByKeyAutoCert(cert_ID('Certificate1'), NULL, EncryptedBirthDate)) AS BirthDate, GL.GradeLevelName AS CurrentGradeLevel,
                      SC.SchoolName, S.ContractSignedDate,
                          (SELECT     Max(G.SemesterEndDate) AS MaxSemesterEndDate
                            FROM          Students.Students AS SS LEFT OUTER JOIN
                                                   Students.GPA AS G ON SS.StudentID = G.StudentID 
							WHERE G.IsDeleted = 0			-- Added Isdeleted here and below for accuracy - JL 7/7/2015
                            GROUP BY SS.StudentID
                            HAVING      (SS.StudentID = S.StudentID) ) AS LastGPADate,
						  (SELECT     Top 1 (G.SemesterUnweighted) AS MaxSemesterUnweighted
                            FROM          Students.Students AS SS LEFT OUTER JOIN
                                                   Students.GPA AS G ON SS.StudentID = G.StudentID 
							WHERE G.IsDeleted = 0			-- Added Isdeleted here and below for accuracy - JL 7/7/2015
                            GROUP BY SS.StudentID, G.SemesterUnweighted, G.SemesterEndDate
                            HAVING      (SS.StudentID = S.StudentID) 
							ORDER By G.SemesterEndDate DESC) AS LastSemesterUnweighted,
						  (SELECT     Top 1 (G.CumulativeUnweighted) AS MaxCumulativeUnweighted
                            FROM          Students.Students AS SS LEFT OUTER JOIN
                                                   Students.GPA AS G ON SS.StudentID = G.StudentID 
							WHERE G.IsDeleted = 0			-- Added Isdeleted here and below for accuracy - JL 7/7/2015
                            GROUP BY SS.StudentID, G.CumulativeUnweighted, G.SemesterEndDate
                            HAVING      (SS.StudentID = S.StudentID) 
							ORDER By G.SemesterEndDate DESC) AS LastCumulativeUnweighted,
						  (SELECT     Top(1) SchoolTermTypeName AS TopTermType
                            FROM       Students.GPA G INNER JOIN
									   Lookups.SchoolTermTypes STT on G.SchoolTermTypeID = STT.SchoolTermTypeID
							WHERE G.IsDeleted =  0
							GROUP BY G.StudentID, G.SemesterEndDate, STT.SchoolTermTypeName, G.SchoolTermTypeID
							
                            HAVING      (G.StudentID = S.StudentID) 
								--AND G.SchoolTermTypeID NOT IN (18,30,0)   -- Switch 18 to 17 to go from Sem 2 to Sem 1 JL 17Jun16
							ORDER By G.SemesterEndDate DESC) AS LastTermType, 	 
					  S.OfficeID, Lookups.StudentStatuses.StudentStatusName, S.StudentStatusID, 
                      S.StudentReferenceID
FROM         Students.Students AS S LEFT OUTER JOIN
                      Lookups.StudentStatuses ON S.StudentStatusID = Lookups.StudentStatuses.StudentStatusID LEFT OUTER JOIN
                      Schools.Schools AS SC ON S.SchoolID = SC.SchoolID LEFT OUTER JOIN
                      Lookups.GradeLevels AS GL ON S.CurrentGradeLevelID = GL.GradeLevelID
WHERE     (S.StudentStatusID In (1,3,4,5))
AND S.IsDeleted = 0
--And (S.OfficeID = 3)  -- Redid date below again for new year JL 9/3/2015
And (S.ContractSignedDate < dbo.Apr1()) -- I redid the bottom on 5/14/2014 JL - It was not showing the right data. Went from 2014-11-01 to 2015-04-01 for Sem 2 JL 17Jun15
--And ((sg.SemesterUnweighted IS NOT NULL And sg.SemesterUnweighted > 0) OR (sg.CumulativeUnweighted IS NOT NULL And sg.CumulativeUnweighted > 0))
AND ((S.StudentID NOT IN   --NOT EXISTS
       --                   (SELECT     sg.StudentID
       --                     FROM          Students.GPA AS sg
       --                     WHERE      (sg.IsDeleted = 0) AND  -- Redid date below for 2015-2016  after Q1 2015
							-- (sg.SemesterEndDate Between '2015-07-01' AND '2015-12-31') -- Switched dates to Sem2 2015  JL 17Jun15 back to sem 1
							--And (sg.SchoolTermTypeID = 18 OR sg.SchoolTermTypeID = 30 OR sg.SchoolTermTypeID = 0)  -- From 17 to 18 for Sem1 to Sem2 JL 17Jun15
							--And ((sg.SemesterUnweighted IS NOT NULL And sg.SemesterUnweighted > 0) 
							--	OR (sg.CumulativeUnweighted IS NOT NULL And sg.CumulativeUnweighted > 0)))))
							--Or (NOT EXISTS
                          (SELECT     TOP (1) StudentID
                            FROM          Students.GPA AS sg
                            WHERE      (S.StudentID = StudentID) 
							AND (sg.SemesterEndDate Between dbo.May1() AND dbo.NextAcadYearAug1())
							AND (sg.SemesterUnweighted > 0 OR CumulativeUnweighted > 0)
							And sg.isdeleted = 0 
							And (sg.SchoolTermTypeID = 18 OR sg.SchoolTermTypeID = 30 OR sg.SchoolTermTypeID = 0))))
			
			--order by LastName, FirstName
