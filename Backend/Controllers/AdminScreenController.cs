using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Backend.Controllers
{
    public class AdminScreenController : Controller
    {
        private readonly IScreenService _screenService;
        private readonly ITheatreService _theatreService;

        public AdminScreenController(IScreenService screenService, ITheatreService theatreService)
        {
            _screenService = screenService;
            _theatreService = theatreService;
        }

        // Hiển thị danh sách phòng chiếu
        public async Task<IActionResult> Index()
        {
            var screens = await _screenService.GetAllScreensAsync();
            return View(screens);
        }

        // Tạo phòng chiếu mới (GET)
        public async Task<IActionResult> Create()
        {
            ViewBag.Theatres = await _theatreService.GetAllTheatresAsync();
            return View();
        }

        // Tạo phòng chiếu mới (POST)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Screen screen)
        {
            if (ModelState.IsValid)
            {
                ViewBag.Theatres = await _theatreService.GetAllTheatresAsync();
                return View(screen);
            }

            await _screenService.AddScreenAsync(screen);
            return RedirectToAction(nameof(Index));
        }

        // Chỉnh sửa phòng chiếu (GET)
        public async Task<IActionResult> Edit(int id)
        {
            var screen = await _screenService.GetScreenByIdAsync(id);
            if (screen == null)
                return NotFound();

            ViewBag.Theatres = await _theatreService.GetAllTheatresAsync();
            return View(screen);
        }

        // Chỉnh sửa phòng chiếu (POST)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, Screen screen)
        {
            if (id != screen.Id)
                return NotFound();

            if (!ModelState.IsValid)
            {
                ViewBag.Theatres = await _theatreService.GetAllTheatresAsync();
                return View(screen);
            }

            await _screenService.UpdateScreenAsync(screen);
            return RedirectToAction(nameof(Index));
        }

        // Xóa phòng chiếu
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            await _screenService.DeleteScreenAsync(id);
            return RedirectToAction(nameof(Index));
        }

        // API: Lấy danh sách phòng chiếu theo rạp
        [HttpGet]
        public async Task<JsonResult> GetScreensByTheatre(int theatreId)
        {
            var theatre = await _theatreService.GetTheatreByIdAsync(theatreId);
            if (theatre == null || theatre.Screens == null)
            {
                return Json(new { success = false, message = "Không tìm thấy rạp hoặc không có phòng chiếu." });
            }

            return Json(theatre.Screens);
        }
    }
}
