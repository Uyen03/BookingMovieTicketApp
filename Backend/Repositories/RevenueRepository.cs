using Backend.DataAccess;
using Backend.Models;
using Backend.Services;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Repositories
{
    public class RevenueRepository : IRevenueService
    {
        private readonly ApplicationDbContext _context;

        public RevenueRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        // Lấy tổng doanh thu
        public async Task<decimal> GetTotalRevenueAsync(DateTime? startDate, DateTime? endDate)
        {
            var bookings = _context.Bookings
                .Where(b => b.Status == "Paid" &&
                            (!startDate.HasValue || b.CreatedAt >= startDate.Value) &&
                            (!endDate.HasValue || b.CreatedAt <= endDate.Value));

            return await bookings.SumAsync(b => b.TotalPrice);
        }

        // Lấy doanh thu theo phim
        public async Task<List<dynamic>> GetRevenueByMovieAsync()
        {
            return await _context.Bookings
                .Where(b => b.Status == "Paid")
                .GroupBy(b => b.Showtime.MovieId)
                .Select(g => new
                {
                    MovieId = g.Key,
                    MovieTitle = _context.Movies.Where(m => m.Id == g.Key).Select(m => m.Title).FirstOrDefault(),
                    Revenue = g.Sum(b => b.TotalPrice)
                })
                .OrderByDescending(r => r.Revenue)
                .ToListAsync<dynamic>();
        }

        // Lấy doanh thu theo rạp
        public async Task<List<dynamic>> GetRevenueByTheatreAsync()
        {
            return await _context.Bookings
                .Where(b => b.Status == "Paid")
                .GroupBy(b => b.Showtime.Screen.TheatreId)
                .Select(g => new
                {
                    TheatreId = g.Key,
                    TheatreName = _context.Theatres.Where(t => t.Id == g.Key).Select(t => t.Name).FirstOrDefault(),
                    Revenue = g.Sum(b => b.TotalPrice)
                })
                .OrderByDescending(r => r.Revenue)
                .ToListAsync<dynamic>();
        }
    }
}
