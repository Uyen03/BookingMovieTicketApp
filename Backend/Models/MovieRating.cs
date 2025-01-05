using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Backend.Models
{
    public class MovieRating
    {
        public int Id { get; set; }

        public int MovieId { get; set; }

        public int UserId { get; set; }

        [Range(1, 10)]
        public int Rating { get; set; }

        [ForeignKey("MovieId")]
        public Movie Movie { get; set; }
    }
}
