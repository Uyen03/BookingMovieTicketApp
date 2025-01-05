using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Backend.Models
{
    public class Showtime
    {
        public int Id { get; set; }

        [Required]
        [ForeignKey("Movie")]
        public int MovieId { get; set; }
        public Movie? Movie { get; set; } // Liên kết với phim

        [Required]
        [ForeignKey("Theatre")]
        public int TheatreId { get; set; }
        public Theatre? Theatre { get; set; } // Liên kết với rạp

        [Required]
        [ForeignKey("Screen")]
        public int ScreenId { get; set; }
        public Screen? Screen { get; set; } // Liên kết với phòng chiếu

        [Required]
        public DateTime StartTime { get; set; } // Thời gian bắt đầu

        [NotMapped]
        public DateTime EndTime => Movie != null ? StartTime.AddMinutes(Movie.DurationInMinutes) : StartTime;

        [Required]
        public string Status { get; set; } = "Active"; // Trạng thái suất chiếu (Active, Cancelled)

        [Required]
        [Column(TypeName = "decimal(10, 2)")]
        public decimal TicketPrice { get; set; } // Giá vé cơ bản theo suất chiếu

        [Column(TypeName = "decimal(5, 2)")]
        public decimal? PriceModifier { get; set; }

        public ICollection<Seat>? Seats { get; set; } // Liên kết với Seat
    }
}
