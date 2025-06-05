namespace LMS.Models
{
    public class SubjectAssignmentByIdRequest
    {
        public int ProgrammeId { get; set; }
        public int BatchId { get; set; }
        public int GroupId { get; set; }
        public int Semester { get; set; }
        public List<int> SubjectIds { get; set; }
    }
}
