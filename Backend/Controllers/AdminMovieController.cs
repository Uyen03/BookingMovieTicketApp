using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Controllers
{
    public class AdminMovieController : Controller
    {
        private readonly IMovieService _movieService;
        private readonly IActorService _actorService;
        private readonly IWebHostEnvironment _webHostEnvironment;

        public AdminMovieController(IMovieService movieService, IActorService actorService, IWebHostEnvironment webHostEnvironment)
        {
            _movieService = movieService;
            _actorService = actorService;
            _webHostEnvironment = webHostEnvironment;
        }

        // Hiển thị danh sách phim
        public async Task<IActionResult> Index()
        {
            var movies = await _movieService.GetAllMoviesAsync();
            return View(movies);
        }

        // Tạo phim mới (GET)
        public async Task<IActionResult> Create()
        {
            ViewBag.Actors = await _actorService.GetAllActorsAsync();
            return View();
        }

        // Tạo phim mới (POST)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Movie movie, List<int> actorIds, IFormFile PosterFile, List<string> Formats, List<string> LanguagesAvailable, string AgeRating)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.Actors = await _actorService.GetAllActorsAsync();
                return View(movie);
            }

            try
            {
                var uploadPath = Path.Combine(_webHostEnvironment.WebRootPath, "uploads");
                if (!Directory.Exists(uploadPath)) Directory.CreateDirectory(uploadPath);

                // Upload Poster
                if (PosterFile != null && PosterFile.Length > 0)
                {
                    var posterPath = Path.Combine(uploadPath, Path.GetFileName(PosterFile.FileName));
                    using (var stream = new FileStream(posterPath, FileMode.Create))
                    {
                        await PosterFile.CopyToAsync(stream);
                    }
                    movie.BannerUrl = $"/uploads/{Path.GetFileName(PosterFile.FileName)}";
                }

                // Gán thêm các thuộc tính khác
                movie.Formats = Formats;
                movie.LanguagesAvailable = LanguagesAvailable;
                movie.AgeRating = AgeRating;

                // Lưu phim vào cơ sở dữ liệu
                await _movieService.AddMovieAsync(movie, actorIds);

                TempData["SuccessMessage"] = "Phim được tạo thành công.";
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                ModelState.AddModelError(string.Empty, "Có lỗi xảy ra khi tạo phim.");
                ViewBag.Actors = await _actorService.GetAllActorsAsync();
                return View(movie);
            }
        }

        // Chỉnh sửa phim (GET)
        public async Task<IActionResult> Edit(int id)
        {
            var movie = await _movieService.GetMovieByIdAsync(id);
            if (movie == null)
                return NotFound();

            ViewBag.Actors = await _actorService.GetAllActorsAsync();
            ViewBag.SelectedActorIds = movie.MovieActors.Select(ma => ma.ActorId).ToList();
            return View(movie);
        }

        // Chỉnh sửa phim (POST)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, Movie movie, List<int> actorIds, IFormFile PosterFile, List<string> Formats, List<string> LanguagesAvailable, string AgeRating)
        {
            if (id != movie.Id)
                return NotFound();

            if (!ModelState.IsValid)
            {
                ViewBag.Actors = await _actorService.GetAllActorsAsync();
                ViewBag.SelectedActorIds = actorIds;
                return View(movie);
            }

            try
            {
                var uploadPath = Path.Combine(_webHostEnvironment.WebRootPath, "uploads");
                if (!Directory.Exists(uploadPath)) Directory.CreateDirectory(uploadPath);

                // Upload Poster
                if (PosterFile != null && PosterFile.Length > 0)
                {
                    var posterPath = Path.Combine(uploadPath, Path.GetFileName(PosterFile.FileName));
                    using (var stream = new FileStream(posterPath, FileMode.Create))
                    {
                        await PosterFile.CopyToAsync(stream);
                    }
                    movie.BannerUrl = $"/uploads/{Path.GetFileName(PosterFile.FileName)}";
                }

                // Gán thêm các thuộc tính khác
                movie.Formats = Formats;
                movie.LanguagesAvailable = LanguagesAvailable;
                movie.AgeRating = AgeRating;

                // Cập nhật phim vào cơ sở dữ liệu
                await _movieService.UpdateMovieAsync(movie, actorIds);

                TempData["SuccessMessage"] = "Cập nhật phim thành công.";
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                ModelState.AddModelError(string.Empty, "Có lỗi xảy ra khi chỉnh sửa phim.");
                ViewBag.Actors = await _actorService.GetAllActorsAsync();
                return View(movie);
            }
        }

        // Xóa phim
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                await _movieService.DeleteMovieAsync(id);
                TempData["SuccessMessage"] = "Xóa phim thành công.";
                return RedirectToAction(nameof(Index));
            }
            catch
            {
                TempData["ErrorMessage"] = "Có lỗi xảy ra khi xóa phim.";
                return RedirectToAction(nameof(Index));
            }
        }
    }
}
