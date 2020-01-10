SELECT
    s.LastName + ', ' + s.FirstName AS StudentName,
    s.MiddleName, m.LastName + ', ' + m.FirstName As MentorName,
    st.LastName +', '+st.FirstName as AdvocateName,
    m.MentorID,
    sm.MentorAssignmentTypeID,
    s.StudentStatusID,
    s.StudentReferenceID,
    s.OfficeID,
    s.CurrentGradeLevelID,
    s.ContractSignedDate,
    ss.StudentStatusName,
    sch.SchoolName,
    c.CountyName,
    sms.SessionDate,
    mentorsessiontypename AS SessionType,
    sms.SessionNote,
    sms.SessionDuration,
    s.Affiliation,
    s.i3ControlGroup,
    i3StudyGroupMember,
    MentorStatusName,
    sm.assigneddate
      --, os.Donor
      --( Select Top (1) Donor
      --  From Offices.Scholarships
      --  Where Offices.Scholarships.StudentID = s.StudentID and Offices.Scholarships.isdeleted = 0) As DonorName
FROM  Students.Students AS s
INNER JOIN Lookups.StudentStatuses AS ss ON s.StudentStatusID = ss.StudentStatusID
INNER JOIN Schools.Schools AS sch ON s.SchoolID = sch.SchoolID
INNER JOIN Lookups.Counties AS c ON s.CountyID = c.CountyID
LEFT OUTER JOIN offices.Staff ST on s.AdvocateID =  st.StaffID
--Left outer Join-- Offices.Scholarships os ON s.StudentID = os.StudentID
LEFT OUTER JOIN Students.StudentMentors AS sm ON s.StudentID = sm.StudentID --AND (sm.UnassignedDate < '2017-08-01' OR sm.UnassignedDate IS NULL) --AND sm.MentorAssignmentTypeID = 1
INNER JOIN Mentors.Mentors AS m ON sm.MentorID = m.MentorID
LEFT OUTER JOIN Students.MentoringSessions AS sms ON s.StudentID = sms.StudentID AND m.MentorID = sms.MentorID --And sms.SessionDuration > 0
LEFT JOIN lookups.mentorsessiontypes ON sms.sessiontypeid=mentorsessiontypes.mentorsessiontypeid
INNER JOIN Lookups.MentorStatuses ms ON m.MentorStatusID = ms.MentorStatusID
WHERE 1=1
    AND s.StudentStatusID IN (1,3,4,5)
    AND s.IsDeleted = 0
    AND m.IsDeleted = 0
    AND sm.IsDeleted = 0
    AND sms.IsDeleted = 0
    --And os.IsDeleted = 0
    --And s.OfficeID = 39			--Testing Palm Beach
    --And s.OfficeID = 41			--Testing Pinellas
    --AND sms.SessionDate Between '2014-07-01' And '2015-02-28'
    --ORDER BY StudentName
