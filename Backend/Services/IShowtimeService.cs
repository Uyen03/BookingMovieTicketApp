using Backend.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Backend.Services
{
    public interface IShowtimeService
    {
        Task<List<Showtime>> GetAllShowtimesAsync();
        Task<Showtime> GetShowtimeByIdAsync(int id);
        Task AddShowtimeAsync(Showtime showtime);
        Task UpdateShowtimeAsync(Showtime showtime);
        Task DeleteShowtimeAsync(int id);
        Task<List<Showtime>> GetShowtimesByScreenIdAsync(int screenId);
    }
}
