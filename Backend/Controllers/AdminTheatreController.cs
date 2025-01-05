using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;

namespace Backend.Controllers
{
    public class AdminTheatreController : Controller
    {
        private readonly ITheatreService _theatreService;
        private readonly HttpClient _httpClient;

        public AdminTheatreController(ITheatreService theatreService, HttpClient httpClient)
        {
            _theatreService = theatreService;
            _httpClient = httpClient;
        }

        // Hiển thị danh sách rạp
        [HttpGet]
        public async Task<IActionResult> Index()
        {
            var theatres = await _theatreService.GetAllTheatresAsync();
            return View(theatres);
        }

        // Tạo rạp (GET)
        [HttpGet]
        public async Task<IActionResult> Create()
        {
            ViewBag.Provinces = await GetProvincesAsync();
            ViewBag.ScreenOptions = new List<string> { "2D", "3D", "IMAX", "4DX", "ScreenX" };
            return View();
        }

        // Tạo rạp (POST)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Theatre theatre, string[] AvailableScreens, IFormFile ImageFile)
        {
            ModelState.Remove("Showtimes");

            if (!ModelState.IsValid)
            {
                ViewBag.Provinces = await GetProvincesAsync();
                ViewBag.ScreenOptions = new List<string> { "2D", "3D", "IMAX", "4DX", "ScreenX" };
                return View(theatre);
            }

            // Xử lý tệp hình ảnh
            if (ImageFile != null && ImageFile.Length > 0)
            {
                string fileName = $"{Path.GetFileNameWithoutExtension(ImageFile.FileName)}-{Guid.NewGuid()}{Path.GetExtension(ImageFile.FileName)}";
                string filePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "theatre", fileName);

                if (!Directory.Exists(Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "theatre")))
                {
                    Directory.CreateDirectory(Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "theatre"));
                }

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await ImageFile.CopyToAsync(stream);
                }

                theatre.ImageUrl = $"/theatre/{fileName}";
            }

            theatre.AvailableScreens = string.Join(", ", AvailableScreens);
            await _theatreService.AddTheatreAsync(theatre);
            return RedirectToAction(nameof(Index));
        }

        // Chỉnh sửa rạp (GET)
        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            var theatre = await _theatreService.GetTheatreByIdAsync(id);
            if (theatre == null)
                return NotFound();

            ViewBag.Provinces = await GetProvincesAsync();
            ViewBag.ScreenOptions = new List<string> { "2D", "3D", "IMAX", "4DX", "ScreenX" };
            ViewBag.SelectedScreens = theatre.AvailableScreensList;
            return View(theatre);
        }

        // Chỉnh sửa rạp (POST)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, Theatre theatre, string[] AvailableScreens, IFormFile ImageFile)
        {
            if (id != theatre.Id)
                return NotFound();

            ModelState.Remove("Showtimes");

            if (!ModelState.IsValid)
            {
                ViewBag.Provinces = await GetProvincesAsync();
                ViewBag.ScreenOptions = new List<string> { "2D", "3D", "IMAX", "4DX", "ScreenX" };
                return View(theatre);
            }

            if (ImageFile != null && ImageFile.Length > 0)
            {
                string fileName = $"{Path.GetFileNameWithoutExtension(ImageFile.FileName)}-{Guid.NewGuid()}{Path.GetExtension(ImageFile.FileName)}";
                string filePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "theatre", fileName);

                if (!Directory.Exists(Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "theatre")))
                {
                    Directory.CreateDirectory(Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "theatre"));
                }

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await ImageFile.CopyToAsync(stream);
                }

                theatre.ImageUrl = $"/theatre/{fileName}";
            }

            theatre.AvailableScreens = string.Join(", ", AvailableScreens);
            await _theatreService.UpdateTheatreAsync(theatre);
            return RedirectToAction(nameof(Index));
        }

        // Xóa rạp
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            await _theatreService.DeleteTheatreAsync(id);
            return RedirectToAction(nameof(Index));
        }

        // Lấy danh sách tỉnh/thành phố
        private async Task<List<Province>> GetProvincesAsync()
        {
            var response = await _httpClient.GetAsync("https://provinces.open-api.vn/api/?depth=1");
            response.EnsureSuccessStatusCode();
            var responseBody = await response.Content.ReadAsStringAsync();
            return JsonSerializer.Deserialize<List<Province>>(responseBody);
        }

        // Lấy danh sách quận/huyện theo tỉnh
        [HttpGet]
        public async Task<IActionResult> GetDistricts(string provinceCode)
        {
            try
            {
                var response = await _httpClient.GetAsync($"https://provinces.open-api.vn/api/p/{provinceCode}?depth=2");
                response.EnsureSuccessStatusCode();

                var responseBody = await response.Content.ReadAsStringAsync();
                var provinceData = JsonSerializer.Deserialize<Province>(responseBody);

                return Json(provinceData.Districts);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching districts: {ex.Message}");
                return BadRequest("Không thể lấy danh sách quận/huyện");
            }
        }

        // Lấy danh sách phường/xã theo quận
        [HttpGet]
        public async Task<IActionResult> GetWards(string districtCode)
        {
            try
            {
                var response = await _httpClient.GetAsync($"https://provinces.open-api.vn/api/d/{districtCode}?depth=2");
                response.EnsureSuccessStatusCode();

                var responseBody = await response.Content.ReadAsStringAsync();
                var districtData = JsonSerializer.Deserialize<District>(responseBody);

                return Json(districtData.Wards);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error fetching wards: {ex.Message}");
                return BadRequest("Không thể lấy danh sách phường/xã");
            }
        }
    }
}
