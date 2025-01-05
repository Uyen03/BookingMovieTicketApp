using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Models
{
    public class SeatConfiguration
    {
         public string Row { get; set; } // Ví dụ: "A", "B", "C"
        public int StartColumn { get; set; } // Ví dụ: 3
        public int EndColumn { get; set; } // Ví dụ: 7
        public string Type { get; set; } // Loại ghế: Regular, VIP, Couple
    }
}