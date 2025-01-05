using Microsoft.AspNetCore.Mvc.ModelBinding;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace Backend.Models
{
    public class Booking
    {
        public int Id { get; set; }

        [Required]
        [ForeignKey("User")]
        public string UserId { get; set; }

        [JsonIgnore]
        [BindNever] // Không bao giờ bind từ request
        public User User { get; set; }

        [Required]
        [ForeignKey("Showtime")]
        public int ShowtimeId { get; set; }

        [JsonIgnore]
        [BindNever]
        public Showtime Showtime { get; set; }

        [Required]
        public ICollection<SeatDetail> Seats { get; set; } = new List<SeatDetail>();

        [Required]
        public ICollection<SnackPackage> Snacks { get; set; } = new List<SnackPackage>();

        [Required]
        [Column(TypeName = "decimal(10, 2)")]
        public decimal TotalPrice { get; set; }

        [Required]
        public string Status { get; set; } = "Pending";

        public string? PaymentMethod { get; set; }
        public string? PaymentTransactionId { get; set; }
        public string? PaymentUrl { get; set; }
        public string? PaymentProviderData { get; set; }
        public string? ZaloPayTransToken { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
