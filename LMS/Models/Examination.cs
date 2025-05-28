// File: Models/Examination.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.AspNetCore.Mvc.ModelBinding.Validation;

namespace LMS.Models
{
    public class Examination
    {
        public int ExaminationId { get; set; }

        [Required]
        public int CourseId { get; set; }

        [ForeignKey("CourseId")]
        [ValidateNever]
        public Course Course { get; set; }

        [Required]
        public int GroupId { get; set; }

        [ForeignKey("GroupId")]
        [ValidateNever]
        public Group Group { get; set; }

        [Required]
        public int Semester { get; set; }

        [Required]
        [MaxLength(50)]
        public string PaperCode { get; set; }

        [MaxLength(100)]
        public string PaperName { get; set; }

        public bool IsElective { get; set; }

        [Required]
        public string PaperType { get; set; } // Theory, Practical, Project

        [Range(0, int.MaxValue)]
        public int Credits { get; set; }

        public int InternalMarks1 { get; set; }
        public int InternalMarks2 { get; set; }

        public int TotalInternalMarks { get; set; }
        public int TotalMarks { get; set; }

        public DateTime CreatedDate { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedDate { get; set; } = DateTime.UtcNow;
    }
}
