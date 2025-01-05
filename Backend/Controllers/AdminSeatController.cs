using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

namespace Backend.Controllers
{
    public class AdminSeatController : Controller
    {
        private readonly ISeatService _seatService;
        private readonly IScreenService _screenService;
        private readonly ITheatreService _theatreService;

        public AdminSeatController(ISeatService seatService, IScreenService screenService, ITheatreService theatreService)
        {
            _seatService = seatService;
            _screenService = screenService;
            _theatreService = theatreService;
        }

        // GET: /AdminSeat
        public async Task<IActionResult> Index()
        {
            // Lấy danh sách ghế cùng với thông tin liên quan
            var seats = await _seatService.GetAllSeatsAsync();

            // Chuẩn bị dữ liệu cho View
            var seatViewModels = seats.Select(seat =>
            {
                List<List<SeatDetail>>? seatArrangement = null;

                try
                {
                    seatArrangement = JsonSerializer.Deserialize<List<List<SeatDetail>>>(seat.Arrangement ?? string.Empty);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error deserializing seat {seat.Id}: {ex.Message}");
                }

                return new
                {
                    Seat = seat,
                    TotalSeats = seatArrangement?.Sum(row => row.Count) ?? 0,
                    RegularPrice = seatArrangement?.SelectMany(row => row)
                        .Where(s => s.Type == "Regular")
                        .Select(s => s.AdditionalPrice)
                        .DefaultIfEmpty(0m)
                        .Average(),
                    VipPrice = seatArrangement?.SelectMany(row => row)
                        .Where(s => s.Type == "VIP")
                        .Select(s => s.AdditionalPrice)
                        .DefaultIfEmpty(0m)
                        .Average(),
                    CouplePrice = seatArrangement?.SelectMany(row => row)
                        .Where(s => s.Type == "Couple")
                        .Select(s => s.AdditionalPrice)
                        .DefaultIfEmpty(0m)
                        .Average(),
                    TheatreName = seat.Screen?.Theatre?.Name ?? "Không xác định",
                    ScreenName = seat.Screen?.Name ?? "Không xác định"
                };
            }).ToList();

            return View(seatViewModels);
        }


        // GET: /AdminSeat/Create
        public async Task<IActionResult> Create()
        {
            ViewBag.Theatres = await _theatreService.GetAllTheatresAsync();
            ViewBag.Screens = new List<Screen>();
            return View();
        }

        // POST: /AdminSeat/SaveSeatsForm
        [HttpPost]
        public async Task<IActionResult> SaveSeatsForm(int screenId, string arrangement)
        {
            if (screenId <= 0 || string.IsNullOrWhiteSpace(arrangement))
            {
                return BadRequest(new { Message = "Dữ liệu không hợp lệ." });
            }

            List<List<SeatDetail>>? parsedArrangement;
            try
            {
                parsedArrangement = JsonSerializer.Deserialize<List<List<SeatDetail>>>(arrangement);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deserializing arrangement: {ex.Message}");
                return BadRequest(new { Message = "Sơ đồ ghế không đúng định dạng JSON." });
            }

            var existingSeat = await _seatService.GetSeatsByScreenIdAsync(screenId);
            if (existingSeat != null && existingSeat.Any())
            {
                existingSeat[0].Arrangement = arrangement; // Sửa ghế đầu tiên trong danh sách

                try
                {
                    await _seatService.UpdateSeatAsync(existingSeat[0]);
                    return RedirectToAction("Index");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error updating seat: {ex.Message}");
                    return StatusCode(500, new { Message = "Lỗi khi cập nhật sơ đồ ghế." });
                }
            }

            var newSeat = new Seat
            {
                ScreenId = screenId,
                Arrangement = arrangement
            };

            try
            {
                await _seatService.AddSeatAsync(newSeat);
                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error saving seat: {ex.Message}");
                return StatusCode(500, new { Message = "Lỗi khi lưu sơ đồ ghế." });
            }
        }

        // GET: /AdminSeat/GetScreensByTheatre
        [HttpGet]
        public async Task<JsonResult> GetScreensByTheatre(int theatreId)
        {
            var screens = await _screenService.GetScreensByTheatreIdAsync(theatreId);
            var result = screens.Select(s => new { id = s.Id, name = s.Name }).ToList();
            return Json(result);
        }

        // GET: /AdminSeat/GetSeatArrangement
        [HttpGet]
        public async Task<IActionResult> GetSeatArrangement(int seatId)
        {
            if (seatId <= 0)
            {
                return BadRequest(new { Message = "SeatId không hợp lệ." });
            }

            var seat = await _seatService.GetSeatByIdAsync(seatId);
            if (seat == null)
            {
                return NotFound(new { Message = "Không tìm thấy sơ đồ ghế cho ID này." });
            }

            try
            {
                var seatArrangement = JsonSerializer.Deserialize<List<List<SeatDetail>>>(seat.Arrangement ?? string.Empty);
                return Json(seatArrangement);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deserializing arrangement: {ex.Message}");
                return StatusCode(500, new { Message = "Lỗi khi đọc sơ đồ ghế.", Details = ex.Message });
            }
        }

        // GET: /AdminSeat/Edit
        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            var seat = await _seatService.GetSeatByIdAsync(id);
            if (seat == null)
            {
                return NotFound(new { Message = "Không tìm thấy sơ đồ ghế." });
            }

            ViewBag.Theatres = await _theatreService.GetAllTheatresAsync();
            var screens = await _screenService.GetScreensByTheatreIdAsync(seat.Screen?.Theatre?.Id ?? 0);
            ViewBag.Screens = screens;

            return View(seat);
        }

        // POST: /AdminSeat/Edit
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(Seat updatedSeat)
        {
            if (!ModelState.IsValid)
            {
                ViewBag.Theatres = await _theatreService.GetAllTheatresAsync();
                var screens = await _screenService.GetScreensByTheatreIdAsync(updatedSeat.ScreenId);
                ViewBag.Screens = screens;

                return View(updatedSeat);
            }

            var existingSeat = await _seatService.GetSeatByIdAsync(updatedSeat.Id);
            if (existingSeat == null)
            {
                return NotFound(new { Message = "Không tìm thấy sơ đồ ghế để cập nhật." });
            }

            existingSeat.Arrangement = updatedSeat.Arrangement;
            existingSeat.ScreenId = updatedSeat.ScreenId;

            try
            {
                await _seatService.UpdateSeatAsync(existingSeat);
                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating seat: {ex.Message}");
                return StatusCode(500, new { Message = "Lỗi khi cập nhật sơ đồ ghế." });
            }
        }

        // POST: /AdminSeat/Delete
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            var seat = await _seatService.GetSeatByIdAsync(id);
            if (seat == null)
            {
                return NotFound(new { Message = "Không tìm thấy sơ đồ ghế để xóa." });
            }

            try
            {
                await _seatService.DeleteSeatAsync(id);
                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deleting seat: {ex.Message}");
                return StatusCode(500, new { Message = "Lỗi khi xóa sơ đồ ghế." });
            }
        }
    }
}
