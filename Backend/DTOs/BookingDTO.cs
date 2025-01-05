using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Backend.DTOs
{
    public class BookingCreateDTO
    {
        [Required]
        public string UserId { get; set; } // ID của người dùng
        [Required]
        public int ShowtimeId { get; set; } // ID của suất chiếu
         [Required]
        public List<SeatDTO> Seats { get; set; } = new List<SeatDTO>();
         [Required]
        public List<SnackDTO> Snacks { get; set; } = new List<SnackDTO>();
         [Required]
        public decimal TotalPrice { get; set; }
        public string Status { get; set; } = "Pending"; // Trạng thái mặc định
    }

    public class BookingDTO : BookingCreateDTO
    {
        public int Id { get; set; } // Dùng cho GET hoặc PUT
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class SeatDTO
    {
        public string SeatNumber { get; set; } // Số ghế
        public string Type { get; set; } // Loại ghế (VIP, thường, etc.)
    }

    public class SnackDTO
    {
        public string Name { get; set; }
        public int Quantity { get; set; }
    }

    public class UserDTO
    {
        public string UserId { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
    }
}
