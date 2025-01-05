using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace Backend.Models
{
    public class SeatDetail
    {   
        [Key] // Định nghĩa thuộc tính là Primary Key
        public int Id { get; set; }
        [JsonPropertyName("seatNumber")]
        public string SeatNumber { get; set; } = string.Empty;

        [JsonPropertyName("type")]
        public string Type { get; set; } = "Regular";

        [JsonPropertyName("linkedSeatNumber")]
        public string? LinkedSeatNumber { get; set; }

        [JsonPropertyName("additionalPrice")]
        public decimal AdditionalPrice { get; set; } = 0;

        [JsonPropertyName("status")]
        public string Status { get; set; } = "available"; // available, booked
    }
}