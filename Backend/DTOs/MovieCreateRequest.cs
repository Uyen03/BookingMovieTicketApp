using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Backend.Models;

namespace Backend.DTOs
{
    public class MovieCreateRequest
    {
        public Movie Movie { get; set; }
        public List<int> ActorIds { get; set; }
    }
}