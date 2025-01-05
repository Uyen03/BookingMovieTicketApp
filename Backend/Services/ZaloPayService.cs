using System.Security.Cryptography;
using System.Text;
using Backend.Models;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;

public class ZaloPayService
{
    private readonly ZaloPayConfig _config;

    public ZaloPayService(IOptions<ZaloPayConfig> config)
    {
        _config = config.Value;
    }

    public async Task<string?> CreatePaymentUrlAsync(string bookingId, decimal amount, string userId)
    {
        var appId = _config.AppId;
        var secretKey = _config.SecretKey;
        var appTransId = $"{DateTime.Now:yyyyMMddHHmmss}";
        var description = $"Thanh toán đặt vé {bookingId}";

        var embedData = JsonConvert.SerializeObject(new { BookingId = bookingId });
        var items = JsonConvert.SerializeObject(new[]
        {
            new { name = "Ticket", price = amount, quantity = 1 }
        });

        var data = $"{appId}|{appTransId}|{userId}|{(int)amount}|{description}|{embedData}|{items}";
        var mac = ComputeHmacSHA256(data, secretKey);

        var payload = new Dictionary<string, object>
        {
            {"app_id", appId},
            {"app_trans_id", appTransId},
            {"app_user", userId},
            {"amount", (int)amount},
            {"description", description},
            {"embed_data", embedData},
            {"item", items},
            {"mac", mac},
            {"callback_url", _config.CallbackUrl}
        };

        using var client = new HttpClient();
        var response = await client.PostAsync(
            _config.CreateOrderUrl,
            new StringContent(JsonConvert.SerializeObject(payload), Encoding.UTF8, "application/json")
        );

        if (response.IsSuccessStatusCode)
        {
            var result = JsonConvert.DeserializeObject<Dictionary<string, object>>(await response.Content.ReadAsStringAsync());
            return result?["order_url"]?.ToString(); // Trả về URL thanh toán
        }

        return null;
    }

    private static string ComputeHmacSHA256(string data, string key)
    {
        using var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(key));
        return BitConverter.ToString(hmac.ComputeHash(Encoding.UTF8.GetBytes(data))).Replace("-", "").ToLower();
    }
}
