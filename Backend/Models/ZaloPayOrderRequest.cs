using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Models
{
    public class ZaloPayOrderRequest
    {
         [Required]
    public string UserId { get; set; }

    [Required]
    [Range(1, int.MaxValue, ErrorMessage = "Amount must be greater than 0")]
    public int Amount { get; set; }

    [Required]
    public string Description { get; set; } // Ví dụ: "Thanh toán vé xem phim"

    public string EmbedData { get; set; } // Dữ liệu thêm (nếu có)

    public string Items { get; set; } // Danh sách sản phẩm hoặc dịch vụ
    }
}