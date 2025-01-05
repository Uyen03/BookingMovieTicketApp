using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Backend.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class ActorController : ControllerBase
    {
        private readonly IActorService _actorService;

        public ActorController(IActorService actorService)
        {
            _actorService = actorService;
        }

        // Lấy danh sách tất cả diễn viên
        [HttpGet]
        public async Task<ActionResult<List<Actor>>> GetAllActors()
        {
            var actors = await _actorService.GetAllActorsAsync();
            return Ok(actors);
        }

        // Lấy thông tin diễn viên theo ID
        [HttpGet("{id}")]
        public async Task<ActionResult<Actor>> GetActorById(int id)
        {
            var actor = await _actorService.GetActorByIdAsync(id);
            if (actor == null)
                return NotFound();

            return Ok(actor);
        }

        // Thêm diễn viên mới
        [HttpPost]
        public async Task<ActionResult> CreateActor(Actor actor)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            await _actorService.AddActorAsync(actor);
            return CreatedAtAction(nameof(GetActorById), new { id = actor.Id }, actor);
        }

        // Cập nhật thông tin diễn viên
        [HttpPut("{id}")]
        public async Task<ActionResult> UpdateActor(int id, Actor actor)
        {
            if (id != actor.Id)
                return BadRequest();

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var existingActor = await _actorService.GetActorByIdAsync(id);
            if (existingActor == null)
                return NotFound();

            await _actorService.UpdateActorAsync(actor);
            return NoContent();
        }

        // Xóa diễn viên
        [HttpDelete("{id}")]
        public async Task<ActionResult> DeleteActor(int id)
        {
            var existingActor = await _actorService.GetActorByIdAsync(id);
            if (existingActor == null)
                return NotFound();

            await _actorService.DeleteActorAsync(id);
            return NoContent();
        }
    }
}
