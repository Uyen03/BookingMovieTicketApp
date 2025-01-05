using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.DTOs
{
    public class SeatSaveRequest
    {
        public int ScreenId { get; set; }
        public List<SeatDto> Seats { get; set; }
    }

    public class SeatDto
{
    public string Row { get; set; }
    public int Column { get; set; }
    public string Type { get; set; }
    public string Status { get; set; }
}
}