using Backend.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Backend.Services
{
    public interface IScreenService
    {
        Task<List<Screen>> GetAllScreensAsync();
        Task<Screen> GetScreenByIdAsync(int id);
        Task AddScreenAsync(Screen screen);
        Task UpdateScreenAsync(Screen screen);
        Task DeleteScreenAsync(int id);

        Task<List<Screen>> GetScreensByTheatreIdAsync(int theatreId);
        
    }
}
