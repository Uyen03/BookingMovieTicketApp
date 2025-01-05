using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Models
{
    public class RevenueViewModel
    {
        public string? MovieTitle { get; set; }
        public decimal Revenue { get; set; }
        public int TicketsSold { get; set; }
    }
}