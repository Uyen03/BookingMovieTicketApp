using Backend.DataAccess;
using Backend.Models;
using Backend.Services;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Backend.Repositories
{
    public class ScreenRepository : IScreenService
    {
        private readonly ApplicationDbContext _context;

        public ScreenRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<List<Screen>> GetAllScreensAsync()
        {
            return await _context.Screens.Include(s => s.Theatre).ToListAsync();
        }

        public async Task<Screen> GetScreenByIdAsync(int id)
        {
            return await _context.Screens.Include(s => s.Theatre).FirstOrDefaultAsync(s => s.Id == id);
        }

        public async Task AddScreenAsync(Screen screen)
        {
            _context.Screens.Add(screen);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateScreenAsync(Screen screen)
        {
            _context.Screens.Update(screen);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteScreenAsync(int id)
        {
            var screen = await _context.Screens.FindAsync(id);
            if (screen != null)
            {
                _context.Screens.Remove(screen);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<List<Screen>> GetScreensByTheatreIdAsync(int theatreId)
        {
            return await _context.Screens
                .Where(screen => screen.TheatreId == theatreId)
                .ToListAsync();
        }
    }
}
