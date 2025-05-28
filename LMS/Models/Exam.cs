namespace LMS.Models
{
    public class Exam
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public int CourseId { get; set; }  // Changed from Subject to CourseId
        public DateTime ExamDate { get; set; }
        public int DurationMinutes { get; set; }
        public DateTime CreatedAt { get; set; }

        public int? CreatedBy { get; set; }
        public User? Creator { get; set; }

        public ICollection<ExamQuestion> ExamQuestions { get; set; }

        public Exam()
        {
            ExamQuestions = new List<ExamQuestion>();
        }
    }
}
