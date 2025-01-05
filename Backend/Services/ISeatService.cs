using Backend.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Backend.Services
{
    public interface ISeatService
    {
        Task<List<Seat>> GetAllSeatsAsync();
        Task<List<Seat>> GetSeatsByScreenIdAsync(int screenId);
        // Task<List<Seat>> GetSeatsByScreenAndShowtimeAsync(int screenId, int showtimeId); // Thêm phương thức
        Task<Seat?> GetSeatByIdAsync(int id);
        Task AddSeatAsync(Seat seat);
        Task UpdateSeatAsync(Seat seat);
        Task DeleteSeatAsync(int id);
        Task BulkAddSeatsAsync(List<Seat> seats);
    }
}
