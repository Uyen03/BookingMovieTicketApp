using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers.api
{
    [Route("api/snackpackages")]
    [ApiController]
     public class SnackPackageController : ControllerBase
    {
        private readonly ISnackPackageService _snackPackageService;

        public SnackPackageController(ISnackPackageService snackPackageService)
        {
            _snackPackageService = snackPackageService;
        }

        // GET: /api/snackpackages
        [HttpGet]
        public async Task<ActionResult<IEnumerable<SnackPackage>>> GetAllSnackPackages()
        {
            var snackPackages = await _snackPackageService.GetAllSnackPackagesAsync();
            return Ok(snackPackages);
        }

        // GET: /api/snackpackages/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<SnackPackage>> GetSnackPackageById(Guid id)
        {
            var snackPackage = await _snackPackageService.GetSnackPackageByIdAsync(id);
            if (snackPackage == null)
            {
                return NotFound();
            }
            return Ok(snackPackage);
        }

        // POST: /api/snackpackages
        [HttpPost]
        public async Task<ActionResult<SnackPackage>> CreateSnackPackage([FromBody] SnackPackage snackPackage)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            await _snackPackageService.AddSnackPackageAsync(snackPackage);
            return CreatedAtAction(nameof(GetSnackPackageById), new { id = snackPackage.SnackPackageId }, snackPackage);
        }

        // PUT: /api/snackpackages/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateSnackPackage(Guid id, [FromBody] SnackPackage snackPackage)
        {
            if (id != snackPackage.SnackPackageId)
            {
                return BadRequest();
            }

            await _snackPackageService.UpdateSnackPackageAsync(snackPackage);
            return NoContent();
        }

        // DELETE: /api/snackpackages/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteSnackPackage(Guid id)
        {
            await _snackPackageService.DeleteSnackPackageAsync(id);
            return NoContent();
        }
    }
}