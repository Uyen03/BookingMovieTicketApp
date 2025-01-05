using Backend.DataAccess;
using Backend.Models;
using Backend.Services;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Backend.Repositories
{
    public class ShowtimeRepository : IShowtimeService
    {
        private readonly ApplicationDbContext _context;

        public ShowtimeRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        // Lấy tất cả suất chiếu
        public async Task<List<Showtime>> GetAllShowtimesAsync()
        {
            return await _context.Showtimes
                .Include(s => s.Movie) // Liên kết với Movie
                .Include(s => s.Theatre) // Liên kết với Theatre
                .Include(s => s.Screen) // Liên kết với Screen
                .ToListAsync();
        }

        // Lấy suất chiếu theo ID
        public async Task<Showtime> GetShowtimeByIdAsync(int id)
        {
            return await _context.Showtimes
                .Include(s => s.Movie)
                .Include(s => s.Theatre)
                .FirstOrDefaultAsync(s => s.Id == id);
        }

        // Thêm suất chiếu
        public async Task AddShowtimeAsync(Showtime showtime)
        {
            _context.Showtimes.Add(showtime);
            await _context.SaveChangesAsync();
        }

        // Cập nhật suất chiếu
        public async Task UpdateShowtimeAsync(Showtime showtime)
        {
            _context.Showtimes.Update(showtime);
            await _context.SaveChangesAsync();
        }

        // Xóa suất chiếu
        public async Task DeleteShowtimeAsync(int id)
        {
            var showtime = await _context.Showtimes.FindAsync(id);
            if (showtime != null)
            {
                _context.Showtimes.Remove(showtime);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<List<Showtime>> GetShowtimesByScreenIdAsync(int screenId)
        {
            return await _context.Showtimes
                .Where(showtime => showtime.ScreenId == screenId)
                .ToListAsync();
        }
    }
}
