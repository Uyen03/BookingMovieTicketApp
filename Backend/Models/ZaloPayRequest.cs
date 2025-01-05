using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Models
{
public class ZaloPayRequest
    {
        public string UserId { get; set; } // ID của người dùng
        public int Amount { get; set; }    // Số tiền thanh toán
    }
}