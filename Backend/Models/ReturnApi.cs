using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Models
{
    public class ReturnApi
    {
        public bool success { get; set; } = false;
        public string? message { get; set; } = string.Empty;
        public object? data { get; set; } = null;

        public ReturnApi() { }

        public ReturnApi(bool success, string message = "Đã có lỗi xảy ra, vui lòng kiểm tra lại thông tin !", object data = null!)
        {
            this.success = success;
            this.message = message;
            this.data = data;
        }
    }
}