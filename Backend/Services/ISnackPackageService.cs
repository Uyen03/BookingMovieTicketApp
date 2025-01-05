using Backend.Models;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Backend.Services
{
    public interface ISnackPackageService
    {
        Task<List<SnackPackage>> GetAllSnackPackagesAsync();
        Task<SnackPackage?> GetSnackPackageByIdAsync(Guid id);
        Task AddSnackPackageAsync(SnackPackage snackPackage);
        Task UpdateSnackPackageAsync(SnackPackage snackPackage);
        Task DeleteSnackPackageAsync(Guid id);
    }
}
