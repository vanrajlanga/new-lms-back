//using LMS.Models.DTOs;

//namespace LMS.DTOs
//{
//    public class FeeSummaryDto
//    {
//        public int FeeId { get; set; }
//        public int StudentId { get; set; }
//        public string StudentName { get; set; }
//        public CourseDto Course { get; set; }
//        public string Semester { get; set; }     // ✅ Add this
//        public string Programme { get; set; }
//        public decimal AmountDue { get; set; }
//        public decimal AmountPaid { get; set; }
//        public string FeeStatus { get; set; }
//        public DateTime DueDate { get; set; }
//        public DateTime? PaymentDate { get; set; }
//    }

//    public class PayFeeDto
//    {
//        public int FeeId { get; set; }
//        public decimal Amount { get; set; }
//        public string PaymentMethod { get; set; }
//        public string TransactionId { get; set; }
//    }
//}
using LMS.Models.DTOs;

namespace LMS.DTOs
{
    public class FeeSummaryDto
    {
        public int FeeId { get; set; }
        public int StudentId { get; set; }
        public string StudentName { get; set; }
        public CourseDto Course { get; set; }
        public string Semester { get; set; }
        public string Programme { get; set; }
        public decimal ProgrammeFee { get; set; } // ✅ Added programme fee
        public decimal AmountDue { get; set; }
        public decimal AmountPaid { get; set; }
        public string FeeStatus { get; set; }
        public DateTime DueDate { get; set; }
        public DateTime? PaymentDate { get; set; }
    }

    public class PayFeeDto
    {
        public int FeeId { get; set; }
        public decimal Amount { get; set; }
        public string PaymentMethod { get; set; }
        public string TransactionId { get; set; }
    }
}