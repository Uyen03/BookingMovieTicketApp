using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading.Tasks;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SeatController : ControllerBase
    {
        private readonly ISeatService _seatService;

        public SeatController(ISeatService seatService)
        {
            _seatService = seatService;
        }

        // GET: api/Seat
        [HttpGet]
        public async Task<ActionResult<List<Seat>>> GetAllSeats()
        {
            var seats = await _seatService.GetAllSeatsAsync();
            return Ok(seats);
        }

        // GET: api/Seat/Screen/{screenId}
        [HttpGet("Screen/{screenId}")]
        public async Task<ActionResult<List<Seat>>> GetSeatsByScreenId(int screenId)
        {
            var seats = await _seatService.GetSeatsByScreenIdAsync(screenId);
            if (seats == null || seats.Count == 0)
                return NotFound(new { Message = "Không tìm thấy sơ đồ ghế cho phòng chiếu này." });

            return Ok(seats);
        }

        // POST: api/Seat
        [HttpPost]
        public async Task<ActionResult> AddSeat(Seat seat)
        {
            await _seatService.AddSeatAsync(seat);
            return CreatedAtAction(nameof(GetSeatsByScreenId), new { screenId = seat.ScreenId }, seat);
        }

        // PUT: api/Seat/Screen/{screenId}
        [HttpPut("Screen/{screenId}")]
        public async Task<ActionResult> UpdateSeatArrangement(int screenId, [FromBody] object[][] arrangement)
        {
            if (arrangement == null || arrangement.Length == 0)
                return BadRequest(new { Message = "Dữ liệu sắp xếp ghế không hợp lệ." });

            var seats = await _seatService.GetSeatsByScreenIdAsync(screenId);
            if (seats == null || seats.Count == 0)
                return NotFound(new { Message = "Không tìm thấy sơ đồ ghế cho phòng chiếu này." });

            foreach (var seat in seats)
            {
                seat.Arrangement = JsonSerializer.Serialize(arrangement);
                await _seatService.UpdateSeatAsync(seat);
            }

            return NoContent();
        }

        // DELETE: api/Seat/{id}
        [HttpDelete("{id}")]
        public async Task<ActionResult> DeleteSeat(int id)
        {
            await _seatService.DeleteSeatAsync(id);
            return NoContent();
        }

        // POST: api/Seat/BulkAdd
        [HttpPost("BulkAdd")]
        public async Task<ActionResult> BulkAddSeats([FromBody] List<Seat> seats)
        {
            await _seatService.BulkAddSeatsAsync(seats);
            return Ok();
        }

        // PUT: api/Seat/UpdateSeatStatus
        [HttpPut("UpdateSeatStatus")]
        public async Task<IActionResult> UpdateSeatDetailStatus([FromBody] UpdateSeatDetailStatusRequest request)
        {
            Console.WriteLine($"Updating seats for ScreenId: {request.ScreenId}");
            Console.WriteLine($"Selected Seats: {string.Join(", ", request.SelectedSeats)}");

            if (request.ScreenId <= 0 || request.SelectedSeats == null || !request.SelectedSeats.Any())
            {
                return BadRequest(new { Message = "Invalid data" });
            }

            try
            {
                var seats = await _seatService.GetSeatsByScreenIdAsync(request.ScreenId);
                if (seats == null || seats.Count == 0)
                {
                    return NotFound(new { Message = "No seats found for the specified screen" });
                }

                var updatedSeats = new HashSet<string>(); // Sử dụng HashSet để tránh trùng lặp

                foreach (var seat in seats)
                {
                    if (string.IsNullOrWhiteSpace(seat.Arrangement))
                    {
                        continue;
                    }

                    var seatDetails = JsonSerializer.Deserialize<List<List<SeatDetail>>>(seat.Arrangement);

                    if (seatDetails == null) continue;

                    foreach (var row in seatDetails)
                    {
                        foreach (var seatDetail in row)
                        {
                            if (request.SelectedSeats.Contains(seatDetail.SeatNumber) &&
                                seatDetail.Status != request.Status) // Kiểm tra nếu trạng thái khác
                            {
                                seatDetail.Status = request.Status; // Update status
                                updatedSeats.Add(seatDetail.SeatNumber); // Thêm vào HashSet
                            }
                        }
                    }

                    seat.Arrangement = JsonSerializer.Serialize(seatDetails);
                    await _seatService.UpdateSeatAsync(seat); // Save changes
                }

                return Ok(new
                {
                    Message = "Seat status updated successfully",
                    UpdatedSeats = updatedSeats.ToList() // Chuyển từ HashSet sang List
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error: {ex.Message}");
                return StatusCode(500, new { Message = "Internal Server Error", Details = ex.Message });
            }
        }



        public class UpdateSeatDetailStatusRequest
        {
            public int ScreenId { get; set; }
            public List<string> SelectedSeats { get; set; } = new List<string>();
            public string Status { get; set; } = "booked";
        }
    }
}
