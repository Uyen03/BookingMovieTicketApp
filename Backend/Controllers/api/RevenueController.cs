using Microsoft.AspNetCore.Mvc;
using Backend.Models;
using Microsoft.EntityFrameworkCore;
using Backend.DataAccess;

namespace Backend.Controllers.api
{
    [ApiController]
    [Route("api/[controller]")]
    public class RevenueController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public RevenueController(ApplicationDbContext context)
        {
            _context = context;
        }

        // 1. Tổng doanh thu dự kiến
        [HttpGet("total-pending")]
        public async Task<IActionResult> GetTotalPendingRevenue()
        {
            var totalRevenue = await _context.Bookings
                .Where(b => b.Status == "Pending")
                .SumAsync(b => b.TotalPrice);

            return Ok(new { totalRevenue });
        }

        // 2. Doanh thu dự kiến theo rạp
        [HttpGet("theatre-pending/{theatreId}")]
        public async Task<IActionResult> GetPendingRevenueByTheatre(int theatreId)
        {
            var totalRevenue = await _context.Bookings
                .Where(b => b.Status == "Pending" && b.Showtime.Screen.TheatreId == theatreId)
                .SumAsync(b => b.TotalPrice);

            return Ok(new { theatreId, totalRevenue });
        }

        // 3. Doanh thu dự kiến theo phim
        [HttpGet("movie-pending/{movieId}")]
        public async Task<IActionResult> GetPendingRevenueByMovie(int movieId)
        {
            var totalRevenue = await _context.Bookings
                .Where(b => b.Status == "Pending" && b.Showtime.Movie.Id == movieId)
                .SumAsync(b => b.TotalPrice);

            return Ok(new { movieId, totalRevenue });
        }

        // 4. Doanh thu dự kiến theo phòng chiếu
        [HttpGet("screen-pending/{screenId}")]
        public async Task<IActionResult> GetPendingRevenueByScreen(int screenId)
        {
            var totalRevenue = await _context.Bookings
                .Where(b => b.Status == "Pending" && b.Showtime.Screen.Id == screenId)
                .SumAsync(b => b.TotalPrice);

            return Ok(new { screenId, totalRevenue });
        }

        // 5. Doanh thu dự kiến theo khoảng thời gian
        [HttpGet("time-pending")]
        public async Task<IActionResult> GetPendingRevenueByTimeRange(DateTime startDate, DateTime endDate)
        {
            var totalRevenue = await _context.Bookings
                .Where(b => b.Status == "Pending" && b.CreatedAt >= startDate && b.CreatedAt <= endDate)
                .SumAsync(b => b.TotalPrice);

            return Ok(new { startDate, endDate, totalRevenue });
        }
    }
}
