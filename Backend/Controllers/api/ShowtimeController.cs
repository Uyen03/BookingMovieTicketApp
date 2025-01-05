using Backend.DataAccess;
using Backend.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/showtimes")]
    public class ShowtimeController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public ShowtimeController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/showtimes
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetShowtimes()
        {
            var showtimes = await _context.Showtimes
                .Include(s => s.Movie)
                .Include(s => s.Theatre)
                .Include(s => s.Screen)
                .Select(s => new
                {
                    s.Id,
                    Movie = new
                    {
                        s.Movie.Id,
                        s.Movie.Title,
                        s.Movie.Description,
                        s.Movie.BannerUrl,
                        s.Movie.ReleaseDate,
                        s.Movie.DurationInMinutes,
                        s.Movie.Genres,
                        s.Movie.Formats,
                        s.Movie.LanguagesAvailable,
                        s.Movie.TrailerUrl,
                        s.Movie.AgeRating
                    },
                    Theatre = new
                    {
                        s.Theatre.Id,
                        s.Theatre.Name,
                        s.Theatre.FullAddress,
                        s.Theatre.AvailableScreensList,
                        s.Theatre.ImageUrl
                    },
                    Screen = s.Screen != null ? new { s.Screen.Id, s.Screen.Name } : null,
                    s.StartTime,
                    s.EndTime,
                    s.Status,
                    s.TicketPrice,
                    s.PriceModifier
                })
                .ToListAsync();

            return Ok(showtimes);
        }

        // GET: api/showtimes/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<object>> GetShowtime(int id)
        {
            var showtime = await _context.Showtimes
                .Include(s => s.Movie)
                .Include(s => s.Theatre)
                .Include(s => s.Screen)
                .Select(s => new
                {
                    s.Id,
                    Movie = new
                    {
                        s.Movie.Id,
                        s.Movie.Title,
                        s.Movie.Description,
                        s.Movie.BannerUrl,
                        s.Movie.ReleaseDate,
                        s.Movie.DurationInMinutes,
                        s.Movie.Genres,
                        s.Movie.Formats,
                        s.Movie.LanguagesAvailable,
                        s.Movie.TrailerUrl,
                        s.Movie.AgeRating
                    },
                    Theatre = new
                    {
                        s.Theatre.Id,
                        s.Theatre.Name,
                        s.Theatre.FullAddress,
                        s.Theatre.AvailableScreensList,
                        s.Theatre.ImageUrl
                    },
                    Screen = s.Screen != null ? new { s.Screen.Id, s.Screen.Name } : null,
                    s.StartTime,
                    s.EndTime,
                    s.Status,
                    s.TicketPrice,
                    s.PriceModifier
                })
                .FirstOrDefaultAsync(s => s.Id == id);

            if (showtime == null)
                return NotFound();

            return Ok(showtime);
        }

        // POST: api/showtimes
        [HttpPost]
        public async Task<ActionResult<Showtime>> Create(Showtime showtime)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var theatre = await _context.Theatres.Include(t => t.Screens).FirstOrDefaultAsync(t => t.Id == showtime.TheatreId);
            if (theatre == null || !theatre.Screens.Any(s => s.Id == showtime.ScreenId))
            {
                ModelState.AddModelError("ScreenId", "The selected screen is not available in the selected theatre.");
                return BadRequest(ModelState);
            }

            _context.Showtimes.Add(showtime);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetShowtime), new { id = showtime.Id }, showtime);
        }

        // PUT: api/showtimes/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, Showtime showtime)
        {
            if (id != showtime.Id)
                return BadRequest();

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var theatre = await _context.Theatres.Include(t => t.Screens).FirstOrDefaultAsync(t => t.Id == showtime.TheatreId);
            if (theatre == null || !theatre.Screens.Any(s => s.Id == showtime.ScreenId))
            {
                ModelState.AddModelError("ScreenId", "The selected screen is not available in the selected theatre.");
                return BadRequest(ModelState);
            }

            _context.Entry(showtime).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!ShowtimeExists(id))
                    return NotFound();

                throw;
            }

            return NoContent();
        }

        // DELETE: api/showtimes/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var showtime = await _context.Showtimes.FindAsync(id);
            if (showtime == null)
                return NotFound();

            _context.Showtimes.Remove(showtime);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // Check if a showtime exists by id
        private bool ShowtimeExists(int id)
        {
            return _context.Showtimes.Any(s => s.Id == id);
        }
    }
}
