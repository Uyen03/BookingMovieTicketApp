using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Models
{
    public class Comment
    {
        public int Id { get; set; } // ID của bình luận
        public int MovieId { get; set; } // ID của phim
        public string UserId { get; set; } // ID của người dùng
        public string Username { get; set; } // Tên người dùng
        public string Content { get; set; } // Nội dung bình luận
        public DateTime CreatedAt { get; set; } // Thời gian tạo bình luận
    }
}