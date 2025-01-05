using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace Backend.Models
{
    public class Movie
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Tên phim là bắt buộc.")]
        public string Title { get; set; } = string.Empty;

        public string? Description { get; set; } // Mô tả phim

        public string? BannerUrl { get; set; } // URL ảnh banner

        [Required(ErrorMessage = "Ngày phát hành là bắt buộc.")]
        public DateTime ReleaseDate { get; set; } // Ngày phát hành

        [Range(1, int.MaxValue, ErrorMessage = "Thời lượng phải lớn hơn 0.")]
        public int DurationInMinutes { get; set; } // Thời lượng phim (phút)

        public string? GenresInDb { get; set; } // Lưu chuỗi thể loại trong SQL

        [NotMapped]
        public List<string> Genres
        {
            get => !string.IsNullOrEmpty(GenresInDb)
                ? new List<string>(GenresInDb.Split(',', StringSplitOptions.TrimEntries))
                : new List<string>();
            set => GenresInDb = value != null ? string.Join(", ", value) : string.Empty;
        }

        [Range(0, int.MaxValue, ErrorMessage = "Lượt thích không thể nhỏ hơn 0.")]
        public int Like { get; set; } = 0; // Lượt thích

        [JsonIgnore]
        public ICollection<MovieActor> MovieActors { get; set; } = new List<MovieActor>(); // Danh sách diễn viên và đạo diễn liên kết

        [Required]
        public string Status { get; set; } = "ComingSoon"; // Trạng thái: "NowShowing" hoặc "ComingSoon"

        public string? TrailerUrl { get; set; } // URL trailer phim

        // Các định dạng phim hỗ trợ (VD: "2D, 3D, IMAX")
        public string? FormatsInDb { get; set; }

        [NotMapped]
        public List<string> Formats
        {
            get => !string.IsNullOrEmpty(FormatsInDb)
                ? new List<string>(FormatsInDb.Split(',', StringSplitOptions.TrimEntries))
                : new List<string>();
            set => FormatsInDb = value != null ? string.Join(", ", value) : string.Empty;
        }

        // Các ngôn ngữ hỗ trợ (VD: "Phụ đề Tiếng Việt, Lồng tiếng Tiếng Việt")
        public string? LanguagesAvailableInDb { get; set; }

        [NotMapped]
        public List<string> LanguagesAvailable
        {
            get => !string.IsNullOrEmpty(LanguagesAvailableInDb)
                ? new List<string>(LanguagesAvailableInDb.Split(',', StringSplitOptions.TrimEntries))
                : new List<string>();
            set => LanguagesAvailableInDb = value != null ? string.Join(", ", value) : string.Empty;
        }

        // Phân loại độ tuổi (VD: "P", "C13", "C18")
        public string? AgeRating { get; set; } = "P";
          public ICollection<Showtime> Showtimes { get; set; } = new List<Showtime>();
         
    }
}
