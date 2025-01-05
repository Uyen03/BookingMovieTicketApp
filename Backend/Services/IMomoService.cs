using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Backend.Models;

namespace Backend.Services
{
     public interface IMomoService
{
    Task<string?> CreatePaymentAsync(OrderInfoModel model);
    MomoExecuteResponse PaymentExecuteAsync(IQueryCollection collection);
}
}