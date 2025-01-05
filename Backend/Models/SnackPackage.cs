using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Models
{
    public class SnackPackage
    {
        [Key]
        public Guid SnackPackageId { get; set; } // ID duy nhất của gói

        [Required]
        [StringLength(100)]
        public string Name { get; set; } // Tên gói (VD: "Bắp nước thường", "Combo VIP")

        [Required]
        [Range(0, double.MaxValue)]
        public decimal Price { get; set; } // Giá bán của gói

        public string? Description { get; set; } // Mô tả chi tiết (VD: "1 bắp + 1 nước ngọt")

        [Required]
        public int Quantity { get; set; } // Số lượng tổng cộng trong gói

        [StringLength(255)]
        public string? ImageUrl { get; set; } // URL hình ảnh của gói

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow; // Ngày tạo gói

        public DateTime? UpdatedAt { get; set; } // Ngày cập nhật gói

    }
}