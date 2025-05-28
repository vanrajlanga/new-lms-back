﻿using System.ComponentModel.DataAnnotations;

namespace LMS.Models
{
    public class Question
    {
        public int Id { get; set; }

        [Required]
        public string QuestionText { get; set; }

        public string OptionA { get; set; }
        public string OptionB { get; set; }
        public string OptionC { get; set; }
        public string OptionD { get; set; }

        public string CorrectOption { get; set; }
        public string DifficultyLevel { get; set; }
        public string Subject { get; set; }
        public string Topic { get; set; }


    }
}
