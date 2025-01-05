using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using RestSharp;
using System.Security.Cryptography;
using System.Text;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ZaloPayController : ControllerBase
    {
        private const int AppId = 2554; // AppID từ ZaloPay
        private const string Key1 = "sdngKKJmqEMzvh5QQcdD2A9XBSKUNaYn"; // Key1 từ ZaloPay
        private const string Endpoint = "https://sb-openapi.zalopay.vn/v2/create";

        [HttpPost("create-payment")]
        public async Task<IActionResult> CreatePayment([FromBody] PaymentRequest request)
        {
            Console.WriteLine("debug");
            var embedData = new { redirecturl = "http://localhost:5130/payment-success" };
            var items = new[]
            {
                new { itemid = "123", itemname = "Vé xem phim", itemprice = request.Amount }
            };

            var appTime = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
            var appTransId = $"{DateTime.Now:yyMMdd}_{new Random().Next(100000, 999999)}";
            var data = $"{AppId}|{appTransId}|{request.User}|{request.Amount}|{appTime}|{JsonConvert.SerializeObject(embedData)}|{JsonConvert.SerializeObject(items)}";

            // Tạo HMAC
            var mac = CreateHmac(Key1, data);

            var order = new
            {
                app_id = AppId,
                app_trans_id = appTransId,
                app_user = request.User,
                app_time = appTime,
                amount = request.Amount,
                description = $"Thanh toán vé xem phim: {request.MovieTitle}",
                embed_data = JsonConvert.SerializeObject(embedData),
                item = JsonConvert.SerializeObject(items),
                mac = mac
            };

            // Gửi request đến ZaloPay
            var client = new RestClient();
            var requestZalo = new RestRequest(Endpoint, Method.Post);
            requestZalo.AddJsonBody(order);

            var response = await client.ExecuteAsync(requestZalo);


            // Kiểm tra response từ ZaloPay
            if (response.IsSuccessful)
            {
                var responseContent = JsonConvert.DeserializeObject<dynamic>(response.Content);
                Console.WriteLine(responseContent);

                string payment_url = responseContent.order_url;

                if (responseContent.return_code == 1)
                {
                    return Ok(new { paymentUrl = payment_url });
                }
                else
                {
                    return BadRequest(new { message = responseContent.return_message });
                }
            }

            return BadRequest(new { message = "Không thể tạo thanh toán", details = response.Content });
        }

        private static string CreateHmac(string key, string message)
        {
            var encoding = new UTF8Encoding();
            var keyBytes = encoding.GetBytes(key);
            var messageBytes = encoding.GetBytes(message);

            using var hmacsha256 = new HMACSHA256(keyBytes);
            var hashMessage = hmacsha256.ComputeHash(messageBytes);
            return BitConverter.ToString(hashMessage).Replace("-", "").ToLower();
        }


        public class PaymentRequest
        {
            public int Amount { get; set; }
            public string MovieTitle { get; set; }
            public string User { get; set; } = "testuser";
        }
    }
}