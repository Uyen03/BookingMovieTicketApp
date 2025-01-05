using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Backend.Models
{
    public class Theatre
    {
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = string.Empty; // Tên rạp

        [Required]
        public string FullAddress { get; set; } = string.Empty; // Địa chỉ đầy đủ

        public string? Coordinates { get; set; } // Tọa độ GPS (latitude, longitude)

        public string AvailableScreens { get; set; } = string.Empty; // Danh sách màn hình chiếu

        [NotMapped]
        public List<string> AvailableScreensList
        {
            get => !string.IsNullOrEmpty(AvailableScreens)
                ? new List<string>(AvailableScreens.Split(',', System.StringSplitOptions.TrimEntries))
                : new List<string>();
            set => AvailableScreens = value != null ? string.Join(", ", value) : string.Empty;
        }

        public string Facilities { get; set; } = string.Empty; // Tiện ích của rạp

        [NotMapped]
        public List<string> FacilityList
        {
            get => !string.IsNullOrEmpty(Facilities)
                ? new List<string>(Facilities.Split(',', System.StringSplitOptions.TrimEntries))
                : new List<string>();
            set => Facilities = value != null ? string.Join(", ", value) : string.Empty;
        }

        public string? ContactNumber { get; set; } // Số điện thoại liên hệ

        public string? City { get; set; } // Thành phố
        public string? ImageUrl { get; set; }
        public ICollection<Showtime>? Showtimes { get; set; }
        public ICollection<Screen> Screens { get; set; } = new List<Screen>();
    }
}
