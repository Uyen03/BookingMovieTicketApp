using System;
using System.Collections.Generic;

namespace Backend.DTOs
{
    public class MovieDTO
    {
        public int Id { get; set; }

        public string Title { get; set; }

        public string? Description { get; set; }

        public string? BannerUrl { get; set; }

        public DateTime ReleaseDate { get; set; }

        public int DurationInMinutes { get; set; }

        public List<string> Genres { get; set; } = new List<string>();

        public List<string> Formats { get; set; } = new List<string>(); // Định dạng phim

        public List<string> LanguagesAvailable { get; set; } = new List<string>(); // Ngôn ngữ hỗ trợ

        public string? AgeRating { get; set; } // Phân loại độ tuổi

        public int Like { get; set; }

        public string Status { get; set; }

        public string? TrailerUrl { get; set; }

        public List<ActorDTO> Actors { get; set; } = new List<ActorDTO>();
    }
}
