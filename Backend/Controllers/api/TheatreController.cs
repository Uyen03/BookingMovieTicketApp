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
    [Route("api/theatres")]
    public class TheatreController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public TheatreController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/theatres
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Theatre>>> GetTheatres()
        {
            var theatres = await _context.Theatres.ToListAsync();
            return Ok(theatres);
        }

        // GET: api/theatres/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Theatre>> GetTheatre(int id)
        {
            var theatre = await _context.Theatres.FindAsync(id);
            if (theatre == null)
                return NotFound(new { message = "Rạp không tồn tại." });

            return Ok(theatre);
        }

        // POST: api/theatres
        [HttpPost]
        public async Task<ActionResult<Theatre>> CreateTheatre(Theatre theatre)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            _context.Theatres.Add(theatre);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetTheatre), new { id = theatre.Id }, theatre);
        }

        // PUT: api/theatres/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTheatre(int id, Theatre theatre)
        {
            if (id != theatre.Id)
                return BadRequest(new { message = "ID không khớp." });

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            _context.Entry(theatre).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!_context.Theatres.Any(e => e.Id == id))
                    return NotFound(new { message = "Rạp không tồn tại." });

                throw;
            }

            return NoContent();
        }

        // DELETE: api/theatres/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTheatre(int id)
        {
            var theatre = await _context.Theatres.FindAsync(id);
            if (theatre == null)
                return NotFound(new { message = "Rạp không tồn tại." });

            _context.Theatres.Remove(theatre);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
}
