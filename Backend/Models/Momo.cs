using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Models
{
    public class Momo
    {

    }

    public class MomoResponse
    {
        public string? RequestId { get; set; }
        public int ErrorCode { get; set; }
        public string? OrderId { get; set; }
        public string? Message { get; set; }
        public string? LocalMessage { get; set; }
        public string? RequestType { get; set; }
        public string? PayUrl { get; set; }
        public string? Signature { get; set; }
        public string? QrCodeUrl { get; set; }
        public string? Deeplink { get; set; }
        public string? DeeplinkWebInApp { get; set; }
    }
    public class MomoExecuteResponse
    {
        public int errorCode { get; set; }
        public string? OrderId { get; set; }
        public string? Amount { get; set; }
        public string? OrderInfo { get; set; }
    }
    public class OrderInfoModel
    {
        public string? full_name { get; set; }
        public string? order_id { get; set; }
        public string? order_info { get; set; }
        public double amount { get; set; }
    }
}