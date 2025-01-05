using Backend.DataAccess;
using Backend.Models;
using Backend.Services;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Repositories
{
    public class MovieRepository : IMovieService
    {
        private readonly ApplicationDbContext _context;

        public MovieRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<List<Movie>> GetAllMoviesAsync()
        {
            return await _context.Movies
                .Include(m => m.MovieActors)
                .ThenInclude(ma => ma.Actor)
                .ToListAsync();
        }

        public async Task<Movie?> GetMovieByIdAsync(int id)
        {
            return await _context.Movies
                .Include(m => m.MovieActors)
                .ThenInclude(ma => ma.Actor)
                .FirstOrDefaultAsync(m => m.Id == id);
        }

        public async Task AddMovieAsync(Movie movie, List<int> actorIds)
        {
            // Thêm phim vào CSDL
            _context.Movies.Add(movie);
            await _context.SaveChangesAsync();

            // Thêm các diễn viên liên kết với phim
            foreach (var actorId in actorIds)
            {
                _context.MovieActors.Add(new MovieActor
                {
                    MovieId = movie.Id,
                    ActorId = actorId
                });
            }

            await _context.SaveChangesAsync();
        }

        public async Task UpdateMovieAsync(Movie movie, List<int> actorIds)
        {
            // Cập nhật thông tin phim
            _context.Movies.Update(movie);
            await _context.SaveChangesAsync();

            // Xóa liên kết cũ với diễn viên
            var existingActors = _context.MovieActors.Where(ma => ma.MovieId == movie.Id).ToList();
            _context.MovieActors.RemoveRange(existingActors);

            // Thêm các liên kết mới với diễn viên
            foreach (var actorId in actorIds)
            {
                _context.MovieActors.Add(new MovieActor
                {
                    MovieId = movie.Id,
                    ActorId = actorId
                });
            }

            await _context.SaveChangesAsync();
        }

        public async Task DeleteMovieAsync(int id)
        {
            // Xóa phim khỏi CSDL
            var movie = await _context.Movies.FindAsync(id);
            if (movie != null)
            {
                // Xóa liên kết với diễn viên trước
                var movieActors = _context.MovieActors.Where(ma => ma.MovieId == id);
                _context.MovieActors.RemoveRange(movieActors);

                // Xóa phim
                _context.Movies.Remove(movie);
                await _context.SaveChangesAsync();
            }
        }
    }
}
