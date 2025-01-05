using Backend.Models;
using Backend.DTOs;
using Google.Cloud.Firestore;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Backend.DataAccess;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BookingController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly FirestoreDb _firestoreDb;

        public BookingController(ApplicationDbContext context)
        {
            _context = context;

            var credentialPath = @"C:\\Users\\tranv\\Downloads\\DACN\\movieticketapp-d914f-firebase-adminsdk-2m0f8-77e4dbba83.json";
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", credentialPath);
            _firestoreDb = FirestoreDb.Create("movieticketapp-d914f");
        }

        [HttpPost]
        public async Task<IActionResult> CreateBooking([FromBody] BookingCreateDTO bookingDto)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                // Kiểm tra UserId
                var userDoc = await _firestoreDb.Collection("users").Document(bookingDto.UserId).GetSnapshotAsync();
                if (!userDoc.Exists)
                {
                    Console.WriteLine("Invalid UserId: " + bookingDto.UserId);
                    return BadRequest(new { message = "Invalid UserId" });
                }

                // Kiểm tra ShowtimeId
                var showtimeExists = await _context.Showtimes.AnyAsync(s => s.Id == bookingDto.ShowtimeId);
                if (!showtimeExists)
                {
                    Console.WriteLine("Invalid ShowtimeId: " + bookingDto.ShowtimeId);
                    return BadRequest(new { message = "Invalid ShowtimeId" });
                }

                // Tạo booking
                var booking = new Booking
                {
                    UserId = bookingDto.UserId,
                    ShowtimeId = bookingDto.ShowtimeId,
                    Seats = bookingDto.Seats.Select(s => new SeatDetail
                    {
                        SeatNumber = s.SeatNumber,
                        Type = s.Type
                    }).ToList(),
                    Snacks = bookingDto.Snacks.Select(sn => new SnackPackage
                    {
                        Name = sn.Name,
                        Quantity = sn.Quantity
                    }).ToList(),
                    TotalPrice = bookingDto.TotalPrice,
                    Status = "Pending",
                    CreatedAt = DateTime.UtcNow
                };

                // Lưu vào SQL Server
                _context.Bookings.Add(booking);
                await _context.SaveChangesAsync();

                Console.WriteLine("Booking saved successfully with ID: " + booking.Id);

                return CreatedAtAction(nameof(CreateBooking), new { id = booking.Id }, booking);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error in CreateBooking: " + ex.Message);
                return StatusCode(500, new { message = "Internal Server Error" });
            }
        }

        [HttpGet("{userId}")]
        public async Task<IActionResult> GetBookingByUserId(string userId)
        {
            try
            {
                var bookings = await _context.Bookings
                    .Where(b => b.UserId == userId)
                    .Include(b => b.Showtime)
                        .ThenInclude(s => s.Movie)
                    .Include(b => b.Showtime.Screen)
                    .Include(b => b.Showtime.Screen.Theatre) // Bao gồm Theatre
                    .Select(b => new
                    {
                        bookingId = b.Id,
                        movieTitle = b.Showtime.Movie.Title,
                        theaterName = b.Showtime.Screen.Theatre.Name, // Lấy tên rạp
                        screenName = b.Showtime.Screen.Name, // Lấy tên phòng chiếu
                        showtime = b.Showtime.StartTime.ToString("yyyy-MM-dd HH:mm"),
                        seats = b.Seats.Select(s => s.SeatNumber).ToList(),
                        totalPrice = b.TotalPrice
                    })
                    .ToListAsync();

                return Ok(bookings);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal Server Error" });
            }
        }


        [HttpGet]
        public async Task<IActionResult> GetAllBookings()
        {
            try
            {
                var bookings = await _context.Bookings
                    .Include(b => b.Seats)
                    .Include(b => b.Showtime)
                        .ThenInclude(s => s.Movie)
                    .Include(b => b.Showtime.Screen)
                    .Select(b => new
                    {
                        bookingId = b.Id,
                        userId = b.UserId,
                        movieTitle = b.Showtime.Movie.Title ?? "Unknown Movie",
                        theaterName = b.Showtime.Screen.Name ?? "Unknown Theater",
                        showtime = b.Showtime.StartTime.ToString("yyyy-MM-dd HH:mm"),
                        seats = b.Seats.Select(s => s.SeatNumber).ToList(),
                        totalPrice = b.TotalPrice,
                        status = b.Status,
                        createdAt = b.CreatedAt
                    })
                    .ToListAsync();

                return Ok(bookings);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error in GetAllBookings: " + ex.Message);
                return StatusCode(500, new { message = "Internal Server Error" });
            }
        }
    }
}
