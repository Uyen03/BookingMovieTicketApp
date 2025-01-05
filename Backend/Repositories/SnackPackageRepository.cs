using Backend.DataAccess;
using Backend.Models;
using Backend.Services;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Backend.Repositories
{
    public class SnackPackageRepository : ISnackPackageService
    {
        private readonly ApplicationDbContext _context;

        public SnackPackageRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<List<SnackPackage>> GetAllSnackPackagesAsync()
        {
            return await _context.SnackPackages.ToListAsync();
        }

        public async Task<SnackPackage?> GetSnackPackageByIdAsync(Guid id)
        {
            return await _context.SnackPackages.FirstOrDefaultAsync(s => s.SnackPackageId == id);
        }

        public async Task AddSnackPackageAsync(SnackPackage snackPackage)
        {
            _context.SnackPackages.Add(snackPackage);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateSnackPackageAsync(SnackPackage snackPackage)
        {
            _context.SnackPackages.Update(snackPackage);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteSnackPackageAsync(Guid id)
        {
            var snackPackage = await _context.SnackPackages.FindAsync(id);
            if (snackPackage != null)
            {
                _context.SnackPackages.Remove(snackPackage);
                await _context.SaveChangesAsync();
            }
        }
    }
}
