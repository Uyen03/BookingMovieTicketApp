using Backend.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Backend.Services
{
    public interface ITheatreService
    {
        Task<List<Theatre>> GetAllTheatresAsync();
        Task<Theatre?> GetTheatreByIdAsync(int id);
        Task AddTheatreAsync(Theatre theatre);
        Task UpdateTheatreAsync(Theatre theatre);
        Task DeleteTheatreAsync(int id);
        
    }
}
