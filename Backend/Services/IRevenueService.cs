using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Backend.Services
{
    public interface IRevenueService
    {
        Task<decimal> GetTotalRevenueAsync(DateTime? startDate, DateTime? endDate);
        Task<List<dynamic>> GetRevenueByMovieAsync();
        Task<List<dynamic>> GetRevenueByTheatreAsync();
    }
}
