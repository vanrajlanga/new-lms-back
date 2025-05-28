public class StudentListDto
{
    public int UserId { get; set; }
    public string Username { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public string Email { get; set; }
    public string PhoneNumber { get; set; }
    public string ProfilePhotoUrl { get; set; }
    public string Status { get; set; }
    public string Role { get; set; }

    public List<ExtendedCourseDto> Courses { get; set; } // ✅ list of enrolled courses
}

public class ExtendedCourseDto
{
    public int CourseId { get; set; }
    public string Name { get; set; }
    public string Programme { get; set; }
    public string Semester { get; set; }
}
