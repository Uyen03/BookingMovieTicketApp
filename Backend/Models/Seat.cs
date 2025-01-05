using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Backend.Models
{
    public class Seat
    {
        public int Id { get; set; }

        [Required]
        [ForeignKey("Screen")]
        public int ScreenId { get; set; }
        public Screen? Screen { get; set; }

        [Required]
        public string? Arrangement { get; set; }



    }


}
