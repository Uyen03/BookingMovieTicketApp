using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Models
{
    public class ZaloPayConfig
    {
        public string AppId { get; set; }
        public string SecretKey { get; set; }
        public string CreateOrderUrl { get; set; }
        public string CallbackUrl { get; set; }
    }
}