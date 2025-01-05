using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Backend.Models
{
    public class Screen
    {
        public int Id { get; set; } // ID phòng chiếu

        [Required]
        public string Name { get; set; } = string.Empty; // Tên phòng chiếu

        [Required]
        public int TheatreId { get; set; } // Thuộc rạp nào
        public Theatre Theatre { get; set; } = null!;

        public ICollection<Showtime> Showtimes { get; set; } = new List<Showtime>();
    }
}
