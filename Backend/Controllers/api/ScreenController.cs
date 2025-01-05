using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/screens")]
    public class ScreenController : ControllerBase
    {
        private readonly IScreenService _screenService;

        public ScreenController(IScreenService screenService)
        {
            _screenService = screenService;
        }

        // GET: api/screens
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Screen>>> GetAllScreens()
        {
            var screens = await _screenService.GetAllScreensAsync();
            return Ok(screens);
        }

        // GET: api/screens/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<Screen>> GetScreenById(int id)
        {
            var screen = await _screenService.GetScreenByIdAsync(id);
            if (screen == null)
            {
                return NotFound(new { Message = $"Screen with ID {id} not found." });
            }
            return Ok(screen);
        }

        // POST: api/screens
        [HttpPost]
        public async Task<IActionResult> CreateScreen([FromBody] Screen screen)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            await _screenService.AddScreenAsync(screen);
            return CreatedAtAction(nameof(GetScreenById), new { id = screen.Id }, screen);
        }

        // PUT: api/screens/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateScreen(int id, [FromBody] Screen screen)
        {
            if (id != screen.Id)
            {
                return BadRequest(new { Message = "Screen ID mismatch." });
            }

            var existingScreen = await _screenService.GetScreenByIdAsync(id);
            if (existingScreen == null)
            {
                return NotFound(new { Message = $"Screen with ID {id} not found." });
            }

            await _screenService.UpdateScreenAsync(screen);
            return NoContent();
        }

        // DELETE: api/screens/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteScreen(int id)
        {
            var screen = await _screenService.GetScreenByIdAsync(id);
            if (screen == null)
            {
                return NotFound(new { Message = $"Screen with ID {id} not found." });
            }

            await _screenService.DeleteScreenAsync(id);
            return NoContent();
        }
    }
}
