using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations; // Để sử dụng [Required], [Range], [NotMapped]
using System.ComponentModel.DataAnnotations.Schema; // Để sử dụng [ForeignKey], [NotMapped]
using System.Text.Json.Serialization;



namespace Backend.Models
{
    public class MovieActor
    {
         public int Id { get; set; }

        [ForeignKey("Movie")]
        public int MovieId { get; set; }
        public Movie Movie { get; set; }

        [ForeignKey("Actor")]
        public int ActorId { get; set; }
        [JsonIgnore]
        public Actor Actor { get; set; }
    }
}