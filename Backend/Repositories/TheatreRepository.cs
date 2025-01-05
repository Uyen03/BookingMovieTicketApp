using Backend.DataAccess;
using Backend.Models;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;
using Backend.Services;

namespace Backend.Repositories
{
    public class TheatreRepository : ITheatreService
    {
        private readonly ApplicationDbContext _context;

        public TheatreRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<List<Theatre>> GetAllTheatresAsync()
        {
            return await _context.Theatres.ToListAsync();
        }

        public async Task<Theatre?> GetTheatreByIdAsync(int id)
        {
            return await _context.Theatres.FirstOrDefaultAsync(t => t.Id == id);
        }

        public async Task AddTheatreAsync(Theatre theatre)
        {
            _context.Theatres.Add(theatre);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateTheatreAsync(Theatre theatre)
        {
            _context.Theatres.Update(theatre);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteTheatreAsync(int id)
        {
            var theatre = await _context.Theatres.FindAsync(id);
            if (theatre != null)
            {
                _context.Theatres.Remove(theatre);
                await _context.SaveChangesAsync();
            }
        }
    }
}
