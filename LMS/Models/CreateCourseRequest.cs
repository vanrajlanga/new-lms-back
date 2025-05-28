﻿namespace LMS.Models
{
    public class CreateCourseRequest
    {
        public string Name { get; set; }
        public string CourseCode { get; set; }
        public string Semester { get; set; }
        public int Credits { get; set; }
        public string CourseDescription { get; set; }
    }
}
