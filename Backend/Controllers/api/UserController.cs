using Backend.DataAccess;
using Backend.Models;
using Google.Cloud.Firestore;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/users")]
    public class UserController : ControllerBase
    {
        private readonly FirestoreDb _firestoreDb;
        private const string CollectionName = "users"; // Tên collection trên Firestore

        public UserController(FirestoreService firestoreService)
        {
            _firestoreDb = firestoreService.GetFirestoreDb();
        }

        // GET: api/users
        [HttpGet]
        public async Task<ActionResult<IEnumerable<User>>> GetUsers()
        {
            var users = new List<User>();
            var snapshot = await _firestoreDb.Collection(CollectionName).GetSnapshotAsync();

            foreach (var doc in snapshot.Documents)
            {
                if (doc.Exists)
                {
                    var user = doc.ConvertTo<User>();
                    users.Add(user);
                }
            }

            return Ok(users);
        }

        // GET: api/users/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<User>> GetUser(string id)
        {
            var docRef = _firestoreDb.Collection(CollectionName).Document(id);
            var snapshot = await docRef.GetSnapshotAsync();

            if (!snapshot.Exists)
                return NotFound();

            var user = snapshot.ConvertTo<User>();
            return Ok(user);
        }

        // POST: api/users
        [HttpPost]
        public async Task<ActionResult<User>> Create(User user)
        {
            var docRef = _firestoreDb.Collection(CollectionName).Document(user.UserId);
            await docRef.SetAsync(user);

            return CreatedAtAction(nameof(GetUser), new { id = user.UserId }, user);
        }

        // PUT: api/users/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, User user)
        {
            if (id != user.UserId)
                return BadRequest();

            var docRef = _firestoreDb.Collection(CollectionName).Document(id);
            var snapshot = await docRef.GetSnapshotAsync();

            if (!snapshot.Exists)
                return NotFound();

            await docRef.SetAsync(user, SetOptions.Overwrite);
            return NoContent();
        }

        // DELETE: api/users/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            var docRef = _firestoreDb.Collection(CollectionName).Document(id);
            var snapshot = await docRef.GetSnapshotAsync();

            if (!snapshot.Exists)
                return NotFound();

            await docRef.DeleteAsync();
            return NoContent();
        }
    }
}
