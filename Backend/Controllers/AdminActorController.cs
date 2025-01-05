using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using System.IO;
using System.Threading.Tasks;

namespace Backend.Controllers
{
    public class AdminActorController : Controller
    {
        private readonly IActorService _actorService;
        private readonly IWebHostEnvironment _environment;

        public AdminActorController(IActorService actorService, IWebHostEnvironment environment)
        {
            _actorService = actorService;
            _environment = environment;
        }

        // Hiển thị danh sách diễn viên
        [HttpGet]
        public async Task<IActionResult> Index()
        {
            var actors = await _actorService.GetAllActorsAsync();
            return View(actors);
        }

        // Tạo diễn viên mới (GET)
        [HttpGet]
        public IActionResult Create()
        {
            return View();
        }

        // Tạo diễn viên mới (POST)
            [HttpPost]
            [ValidateAntiForgeryToken]
            public async Task<IActionResult> Create(Actor actor, IFormFile ProfilePicture)
            {
                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                    Console.WriteLine("ModelState Errors: " + string.Join(", ", errors));
                    return View(actor);
                }

                if (ProfilePicture != null && ProfilePicture.Length > 0)
                {
                    try
                    {
                        var uploadPath = Path.Combine(_environment.WebRootPath, "actor");
                        if (!Directory.Exists(uploadPath))
                        {
                            Directory.CreateDirectory(uploadPath);
                            Console.WriteLine("Created directory: " + uploadPath);
                        }

                        var fileName = $"{Path.GetFileNameWithoutExtension(ProfilePicture.FileName)}-{Guid.NewGuid()}{Path.GetExtension(ProfilePicture.FileName)}";
                        var filePath = Path.Combine(uploadPath, fileName);

                        using (var stream = new FileStream(filePath, FileMode.Create))
                        {
                            await ProfilePicture.CopyToAsync(stream);
                        }

                        actor.ProfilePictureUrl = $"/actor/{fileName}";
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine("Error uploading file: " + ex.Message);
                        ModelState.AddModelError("ProfilePicture", "Không thể tải lên file ảnh. Vui lòng thử lại.");
                        return View(actor);
                    }
                }

                await _actorService.AddActorAsync(actor);
                return RedirectToAction(nameof(Index));
}

        // Chỉnh sửa diễn viên (GET)
        [HttpGet]
        public async Task<IActionResult> Edit(int id)
        {
            var actor = await _actorService.GetActorByIdAsync(id);
            if (actor == null)
                return NotFound();

            return View(actor);
        }

        // Chỉnh sửa diễn viên (POST)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, Actor actor, IFormFile ProfilePicture)
        {
            if (id != actor.Id)
                return BadRequest();

            if (!ModelState.IsValid)
                return View(actor);

            if (ProfilePicture != null && ProfilePicture.Length > 0)
            {
                var uploadPath = Path.Combine(_environment.WebRootPath, "actor");
                if (!Directory.Exists(uploadPath))
                {
                    Directory.CreateDirectory(uploadPath);
                }

                var fileName = $"{Path.GetFileNameWithoutExtension(ProfilePicture.FileName)}-{Guid.NewGuid()}{Path.GetExtension(ProfilePicture.FileName)}";
                var filePath = Path.Combine(uploadPath, fileName);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await ProfilePicture.CopyToAsync(stream);
                }

                actor.ProfilePictureUrl = $"/actor/{fileName}";
            }

            await _actorService.UpdateActorAsync(actor);
            return RedirectToAction(nameof(Index));
        }

        // Xóa diễn viên
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            var actor = await _actorService.GetActorByIdAsync(id);
            if (actor == null)
                return NotFound();

            // Optional: Xóa file ảnh của diễn viên nếu cần
            if (!string.IsNullOrEmpty(actor.ProfilePictureUrl))
            {
                var filePath = Path.Combine(_environment.WebRootPath, actor.ProfilePictureUrl.TrimStart('/'));
                if (System.IO.File.Exists(filePath))
                {
                    System.IO.File.Delete(filePath);
                }
            }

            await _actorService.DeleteActorAsync(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
