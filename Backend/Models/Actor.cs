using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;



namespace Backend.Models
{
    public class Actor
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Tên diễn viên/đạo diễn là bắt buộc.")]
        public string Name { get; set; } = string.Empty;

        public string? ProfilePictureUrl { get; set; } // URL ảnh của diễn viên/đạo diễn

        [Required(ErrorMessage = "Vai trò là bắt buộc.")]
        public string Role { get; set; } = "Actor"; // "Actor" hoặc "Director"

        [JsonIgnore]
        public ICollection<MovieActor> MovieActors { get; set; } = new List<MovieActor>();
    }
}
