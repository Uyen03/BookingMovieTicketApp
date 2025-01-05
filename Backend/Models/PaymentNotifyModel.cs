using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Models
{
    public class PaymentNotifyModel
    {
        public string? orderId { get; set; }
        public int errorCode { get; set; }
        public string? message { get; set; }
        public decimal amount { get; set; }
    }
}