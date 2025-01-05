using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Backend.Models;
using Backend.Services;
using Newtonsoft.Json;
using RestSharp;

namespace Backend.Repositories
{
    public class MomoRepository : IMomoService
    {
        string? api_url = "https://test-payment.momo.vn/gw_payment/transactionProcessor";
        string? secret_key = "K951B6PE1waDMi640xX08PD3vg6EkVlz";
        string? access_key = "F8BBA842ECF85";
        string? return_url = "http://localhost:5130/api/payment/momo-return";
        string? notify_url = "http://localhost:5130/api/payment/momo-notify";
        
        string? partner_code = "MOMO";
        string? request_type = "captureMoMoWallet3";
        
        public async Task<string?> CreatePaymentAsync(OrderInfoModel model)
        {
            model.order_info = "Khách hàng: " + model.full_name + ". Nội dung: Thanh toán đặt vé (" + model.order_id + ")";
            var rawData =
                $"partnerCode={partner_code}&accessKey={access_key}&requestId={model.order_id}&amount={model.amount}&orderId={model.order_id}&orderInfo={model.order_info}&returnUrl={return_url}&notifyUrl={notify_url}&extraData=";

            var signature = ComputeHmacSha256(rawData, secret_key);

            if (string.IsNullOrEmpty(api_url))
            {
                throw new InvalidOperationException("API URL is not configured.");
            }
            var client = new RestClient(api_url);
            var request = new RestRequest() { Method = Method.Post };
            request.AddHeader("Content-Type", "application/json; charset=UTF-8");

            // Create an object representing the request data
            var requestData = new
            {
                accessKey = access_key,
                partnerCode = partner_code,
                requestType = request_type,
                notifyUrl = notify_url,
                returnUrl = return_url,
                orderId = model.order_id,
                amount = model.amount.ToString(),
                orderInfo = model.order_info,
                requestId = model.order_id,
                extraData = "",
                signature = signature
            };

            request.AddParameter("application/json", JsonConvert.SerializeObject(requestData), ParameterType.RequestBody);

            var response = await client.ExecuteAsync(request);

            if (response.Content == null)
            {
                throw new InvalidOperationException("Response content is null.");
            }

            var momoResponse = JsonConvert.DeserializeObject<MomoResponse>(response.Content);
            if (momoResponse == null)
            {
                throw new InvalidOperationException("Failed to deserialize Momo response.");
            }

            return momoResponse.PayUrl;
        }

        public MomoExecuteResponse PaymentExecuteAsync(IQueryCollection collection)
        {
            var amount = collection.First(s => s.Key == "amount").Value;
            var orderInfo = collection.First(s => s.Key == "orderInfo").Value;
            var orderId = collection.First(s => s.Key == "orderId").Value;
            int errorCode = int.Parse(collection.First(s => s.Key == "errorCode").Value!);
            return new MomoExecuteResponse()
            {
                errorCode = errorCode,
                Amount = amount,
                OrderId = orderId,
                OrderInfo = orderInfo
            };
        }

        private string ComputeHmacSha256(string message, string? secretKey)
        {
            if (secretKey == null)
            {
                throw new ArgumentNullException(nameof(secretKey));
            }
            var keyBytes = Encoding.UTF8.GetBytes(secretKey);
            var messageBytes = Encoding.UTF8.GetBytes(message);

            byte[] hashBytes;

            using (var hmac = new HMACSHA256(keyBytes))
            {
                hashBytes = hmac.ComputeHash(messageBytes);
            }

            var hashString = BitConverter.ToString(hashBytes).Replace("-", "").ToLower();

            return hashString;
        }
    }
}