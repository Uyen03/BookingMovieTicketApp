using Backend.DataAccess;
using Backend.Models;
using Backend.Services;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Repositories
{
    public class BookingRepository : IBookingService
    {
        private readonly ApplicationDbContext _context;

        public BookingRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<List<Booking>> GetAllBookingsAsync()
        {
            return await _context.Bookings
                .Include(b => b.User)
                .Include(b => b.Showtime)
                .ThenInclude(st => st.Movie)
                .Include(b => b.Showtime.Screen)
                .Include(b => b.Snacks)
                .Include(b => b.Seats)
                .ToListAsync();
        }

        public async Task<Booking?> GetBookingByIdAsync(int id)
        {
            return await _context.Bookings
                .Include(b => b.User)
                .Include(b => b.Showtime)
                .ThenInclude(st => st.Movie)
                .Include(b => b.Showtime.Screen)
                .Include(b => b.Snacks)
                .Include(b => b.Seats)
                .FirstOrDefaultAsync(b => b.Id == id);
        }

        public async Task AddBookingAsync(Booking booking)
        {
            _context.Bookings.Add(booking);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateBookingAsync(Booking booking)
        {
            _context.Bookings.Update(booking);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteBookingAsync(int id)
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking != null)
            {
                _context.Bookings.Remove(booking);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<List<Booking>> GetBookingsByShowtimeIdAsync(int showtimeId)
        {
            return await _context.Bookings
                .Include(b => b.User)
                .Include(b => b.Showtime)
                .ThenInclude(st => st.Movie)
                .Include(b => b.Showtime.Screen)
                .Include(b => b.Snacks)
                .Include(b => b.Seats)
                .Where(b => b.ShowtimeId == showtimeId)
                .ToListAsync();
        }
    }
}
