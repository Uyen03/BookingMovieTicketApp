using Microsoft.AspNetCore.Mvc;
using Backend.Models;
using Microsoft.EntityFrameworkCore;
using Backend.DataAccess;

namespace Backend.Controllers
{
    public class AdminRevenueController : Controller
    {
        private readonly ApplicationDbContext _context;

        public AdminRevenueController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> RevenueDashboard()
        {
            // Tổng doanh thu dự kiến
            var totalRevenue = await _context.Bookings
                .Where(b => b.Status == "Pending")
                .SumAsync(b => b.TotalPrice);

            // Doanh thu theo rạp
            var revenueByTheatre = await _context.Bookings
                .Where(b => b.Status == "Pending")
                .Include(b => b.Showtime.Screen.Theatre)
                .GroupBy(b => b.Showtime.Screen.Theatre.Name)
                .Select(group => new
                {
                    TheatreName = group.Key,
                    TotalRevenue = group.Sum(b => b.TotalPrice)
                })
                .ToListAsync();

            // Doanh thu theo phim
            var revenueByMovie = await _context.Bookings
                .Where(b => b.Status == "Pending")
                .Include(b => b.Showtime.Movie)
                .GroupBy(b => b.Showtime.Movie.Title)
                .Select(group => new
                {
                    MovieTitle = group.Key,
                    TotalRevenue = group.Sum(b => b.TotalPrice)
                })
                .ToListAsync();

            // Truyền dữ liệu đến view
            ViewBag.TotalPendingRevenue = totalRevenue;
            ViewBag.RevenueByTheatre = revenueByTheatre;
            ViewBag.RevenueByMovie = revenueByMovie;

            return View();
        }
    }
}
