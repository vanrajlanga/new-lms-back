// LMS.Models.DTOs.CourseDto.cs (or any appropriate folder)
namespace LMS.Models.DTOs
{
    public class CourseDto
    {
        public int CourseId { get; set; }
        public string Name { get; set; }
        public string CourseCode { get; set; }
        public int Credits { get; set; }
        public string CourseDescription { get; set; }
        public string Semester { get; set; }
        public string Programme { get; set; }
    }
}
