using Backend.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Backend.Services
{
    public interface IMovieService
    {
        Task<List<Movie>> GetAllMoviesAsync();
        Task<Movie?> GetMovieByIdAsync(int id);
        Task AddMovieAsync(Movie movie, List<int> actorIds);
        Task UpdateMovieAsync(Movie movie, List<int> actorIds);
        Task DeleteMovieAsync(int id);
    }
}
