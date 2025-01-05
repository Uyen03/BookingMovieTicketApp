using Backend.DataAccess;
using Backend.DTOs;
using Backend.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/movies")]
    public class MovieController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public MovieController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/movies
        [HttpGet]
        public async Task<ActionResult<IEnumerable<MovieDTO>>> GetMovies()
        {
            var baseUrl = $"{Request.Scheme}://{Request.Host}";

            var movies = await _context.Movies
                .Include(m => m.MovieActors)
                .ThenInclude(ma => ma.Actor)
                .ToListAsync();

            var movieDTOs = movies.Select(movie => new MovieDTO
            {
                Id = movie.Id,
                Title = movie.Title,
                Description = movie.Description,
                BannerUrl = $"{baseUrl}{movie.BannerUrl}", // Thêm base URL
                ReleaseDate = movie.ReleaseDate,
                DurationInMinutes = movie.DurationInMinutes,
                Genres = movie.Genres,
                Formats = movie.Formats, // Định dạng phim
                LanguagesAvailable = movie.LanguagesAvailable, // Ngôn ngữ phim
                AgeRating = movie.AgeRating, // Phân loại độ tuổi
                Like = movie.Like,
                Status = movie.Status,
                TrailerUrl = $"{baseUrl}{movie.TrailerUrl}", // Thêm base URL
                Actors = movie.MovieActors.Select(ma => new ActorDTO
                {
                    Id = ma.Actor.Id,
                    Name = ma.Actor.Name,
                    ProfilePictureUrl = $"{baseUrl}{ma.Actor.ProfilePictureUrl}", // Thêm base URL
                    Role = ma.Actor.Role
                }).ToList()
            }).ToList();

            return Ok(movieDTOs);
        }

        // GET: api/movies/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<MovieDTO>> GetMovie(int id)
        {
            var movie = await _context.Movies
                .Include(m => m.MovieActors)
                .ThenInclude(ma => ma.Actor)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (movie == null) return NotFound();

            var movieDTO = new MovieDTO
            {
                Id = movie.Id,
                Title = movie.Title,
                Description = movie.Description,
                BannerUrl = movie.BannerUrl,
                ReleaseDate = movie.ReleaseDate,
                DurationInMinutes = movie.DurationInMinutes,
                Genres = movie.Genres,
                Formats = movie.Formats, // Định dạng phim
                LanguagesAvailable = movie.LanguagesAvailable, // Ngôn ngữ phim
                AgeRating = movie.AgeRating, // Phân loại độ tuổi
                Like = movie.Like,
                Status = movie.Status,
                TrailerUrl = movie.TrailerUrl,
                Actors = movie.MovieActors.Select(ma => new ActorDTO
                {
                    Id = ma.Actor.Id,
                    Name = ma.Actor.Name,
                    ProfilePictureUrl = ma.Actor.ProfilePictureUrl,
                    Role = ma.Actor.Role
                }).ToList()
            };

            return Ok(movieDTO);
        }

        // POST: api/movies
        [HttpPost]
        public async Task<ActionResult<MovieDTO>> CreateMovie([FromBody] MovieDTO request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var movie = new Movie
            {
                Title = request.Title,
                Description = request.Description,
                BannerUrl = request.BannerUrl,
                ReleaseDate = request.ReleaseDate,
                DurationInMinutes = request.DurationInMinutes,
                Genres = request.Genres,
                Formats = request.Formats, // Định dạng phim
                LanguagesAvailable = request.LanguagesAvailable, // Ngôn ngữ phim
                AgeRating = request.AgeRating, // Phân loại độ tuổi
                Status = request.Status,
                TrailerUrl = request.TrailerUrl
            };

            _context.Movies.Add(movie);
            await _context.SaveChangesAsync();

            if (request.Actors != null && request.Actors.Any())
            {
                foreach (var actor in request.Actors)
                {
                    _context.MovieActors.Add(new MovieActor
                    {
                        MovieId = movie.Id,
                        ActorId = actor.Id
                    });
                }
                await _context.SaveChangesAsync();
            }

            return CreatedAtAction(nameof(GetMovie), new { id = movie.Id }, request);
        }

        // PUT: api/movies/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateMovie(int id, [FromBody] MovieDTO request)
        {
            if (id != request.Id)
                return BadRequest();

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var movie = await _context.Movies
                .Include(m => m.MovieActors)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (movie == null) return NotFound();

            movie.Title = request.Title;
            movie.Description = request.Description;
            movie.BannerUrl = request.BannerUrl;
            movie.ReleaseDate = request.ReleaseDate;
            movie.DurationInMinutes = request.DurationInMinutes;
            movie.Genres = request.Genres;
            movie.Formats = request.Formats; // Định dạng phim
            movie.LanguagesAvailable = request.LanguagesAvailable; // Ngôn ngữ phim
            movie.AgeRating = request.AgeRating; // Phân loại độ tuổi
            movie.Status = request.Status;
            movie.TrailerUrl = request.TrailerUrl;

            // Update actors
            _context.MovieActors.RemoveRange(movie.MovieActors);
            if (request.Actors != null && request.Actors.Any())
            {
                foreach (var actor in request.Actors)
                {
                    _context.MovieActors.Add(new MovieActor
                    {
                        MovieId = movie.Id,
                        ActorId = actor.Id
                    });
                }
            }

            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/movies/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteMovie(int id)
        {
            var movie = await _context.Movies.FindAsync(id);
            if (movie == null)
                return NotFound();

            _context.Movies.Remove(movie);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
