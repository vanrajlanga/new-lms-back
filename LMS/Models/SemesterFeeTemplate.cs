using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace LMS.Models
{
    public class SemesterFeeTemplate
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        public string Programme { get; set; }

        public string Semester { get; set; }

        public decimal AmountDue { get; set; }
    }
}
