using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Controllers
{
    public class AdminSnackPackageController : Controller
    {
        private readonly ISnackPackageService _snackPackageService;
        private readonly IWebHostEnvironment _webHostEnvironment;

        public AdminSnackPackageController(ISnackPackageService snackPackageService, IWebHostEnvironment webHostEnvironment)
        {
            _snackPackageService = snackPackageService;
            _webHostEnvironment = webHostEnvironment;
        }

        // Hiển thị danh sách SnackPackage
        public async Task<IActionResult> Index()
        {
            var snackPackages = await _snackPackageService.GetAllSnackPackagesAsync();
            return View(snackPackages);
        }

        // Tạo mới SnackPackage (GET)
        public IActionResult Create()
        {
            return View();
        }

        // Tạo mới SnackPackage (POST)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(SnackPackage snackPackage, IFormFile ImageFile)
        {
            if (!ModelState.IsValid)
            {
                return View(snackPackage);
            }

            // Upload ảnh
            if (ImageFile != null && ImageFile.Length > 0)
            {
                var uploadPath = Path.Combine(_webHostEnvironment.WebRootPath, "uploads");
                if (!Directory.Exists(uploadPath)) Directory.CreateDirectory(uploadPath);

                var filePath = Path.Combine(uploadPath, Path.GetFileName(ImageFile.FileName));
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await ImageFile.CopyToAsync(stream);
                }

                snackPackage.ImageUrl = $"/uploads/{Path.GetFileName(ImageFile.FileName)}";
            }

            await _snackPackageService.AddSnackPackageAsync(snackPackage);
            return RedirectToAction(nameof(Index));
        }

        // Chỉnh sửa SnackPackage (GET)
        public async Task<IActionResult> Edit(Guid id)
        {
            var snackPackage = await _snackPackageService.GetSnackPackageByIdAsync(id);
            if (snackPackage == null)
            {
                return NotFound();
            }

            return View(snackPackage);
        }

        // Chỉnh sửa SnackPackage (POST)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Guid id, SnackPackage snackPackage, IFormFile ImageFile)
        {
            if (id != snackPackage.SnackPackageId)
            {
                return NotFound();
            }

            if (!ModelState.IsValid)
            {
                return View(snackPackage);
            }

            // Upload ảnh mới nếu có
            if (ImageFile != null && ImageFile.Length > 0)
            {
                var uploadPath = Path.Combine(_webHostEnvironment.WebRootPath, "uploads");
                if (!Directory.Exists(uploadPath)) Directory.CreateDirectory(uploadPath);

                var filePath = Path.Combine(uploadPath, Path.GetFileName(ImageFile.FileName));
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await ImageFile.CopyToAsync(stream);
                }

                snackPackage.ImageUrl = $"/uploads/{Path.GetFileName(ImageFile.FileName)}";
            }

            await _snackPackageService.UpdateSnackPackageAsync(snackPackage);
            return RedirectToAction(nameof(Index));
        }

        // Xóa SnackPackage
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(Guid id)
        {
            await _snackPackageService.DeleteSnackPackageAsync(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
