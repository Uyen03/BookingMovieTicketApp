using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Controllers
{
    public class AdminShowtimeController : Controller
    {
        private readonly IShowtimeService _showtimeService;
        private readonly IMovieService _movieService;
        private readonly ITheatreService _theatreService;
        private readonly IScreenService _screenService;
        private readonly IBookingService _bookingService;

        public AdminShowtimeController(
            IShowtimeService showtimeService,
            IMovieService movieService,
            ITheatreService theatreService,
            IScreenService screenService,
            IBookingService bookingService)
        {
            _showtimeService = showtimeService;
            _movieService = movieService;
            _theatreService = theatreService;
            _screenService = screenService;
            _bookingService = bookingService;
        }

        // GET: /AdminShowtime
        [HttpGet]
        public async Task<IActionResult> Index()
        {
            var showtimes = await _showtimeService.GetAllShowtimesAsync();
            return View(showtimes);
        }

        // GET: /AdminShowtime/Create
        [HttpGet]
        public async Task<IActionResult> Create()
        {
            await LoadViewData();
            return View();
        }

        // POST: /AdminShowtime/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Showtime showtime)
        {
            if (!ModelState.IsValid)
            {
                await LoadViewData();
                return View(showtime);
            }

            if (!await ValidateScreen(showtime))
            {
                await LoadViewData();
                return View(showtime);
            }

            await _showtimeService.AddShowtimeAsync(showtime);
            return RedirectToAction(nameof(Index));
        }

        // GET: /AdminShowtime/Edit/{id}
        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            var showtime = await _showtimeService.GetShowtimeByIdAsync(id);
            if (showtime == null) return NotFound();

            await LoadViewData();
            return View(showtime);
        }

        // POST: /AdminShowtime/Edit/{id}
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, Showtime showtime)
        {
            if (id != showtime.Id) return NotFound();

            if (!ModelState.IsValid)
            {
                await LoadViewData();
                return View(showtime);
            }

            if (!await ValidateScreen(showtime))
            {
                await LoadViewData();
                return View(showtime);
            }

            await _showtimeService.UpdateShowtimeAsync(showtime);
            return RedirectToAction(nameof(Index));
        }

        // POST: /AdminShowtime/Delete/{id}
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            var relatedBookings = await _bookingService.GetBookingsByShowtimeIdAsync(id);
            if (relatedBookings.Any())
            {
                TempData["Error"] = "Không thể xóa suất chiếu vì đã có vé được đặt.";
                return RedirectToAction(nameof(Index));
            }

            await _showtimeService.DeleteShowtimeAsync(id);
            return RedirectToAction(nameof(Index));
        }

        // GET: /AdminShowtime/GetScreensByTheatre/{theatreId}
        [HttpGet]
        public async Task<JsonResult> GetScreensByTheatre(int theatreId)
        {
            var screens = await _screenService.GetScreensByTheatreIdAsync(theatreId);
            return Json(screens.Select(s => new { id = s.Id, name = s.Name }));
        }

        private async Task<bool> ValidateScreen(Showtime showtime)
        {
            var screens = await _screenService.GetScreensByTheatreIdAsync(showtime.TheatreId);
            if (!screens.Any(s => s.Id == showtime.ScreenId))
            {
                ModelState.AddModelError("ScreenId", "Phòng chiếu không hợp lệ cho rạp đã chọn.");
                return false;
            }
            return true;
        }

        private async Task LoadViewData()
        {
            ViewBag.Movies = await _movieService.GetAllMoviesAsync();
            ViewBag.Theatres = await _theatreService.GetAllTheatresAsync();
        }
    }
}
