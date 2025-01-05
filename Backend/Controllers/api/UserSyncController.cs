using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Backend.DataAccess;
using Backend.Models;
using Google.Cloud.Firestore;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Backend.Controllers.api
{
[ApiController]
[Route("api/[controller]")]
public class UserSyncController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly FirestoreDb _firestoreDb;

    public UserSyncController(ApplicationDbContext context)
    {
        _context = context;

        // Kết nối Firestore
        var credentialPath = @"C:\Users\tranv\Downloads\DACN\movieticketapp-d914f-firebase-adminsdk-2m0f8-77e4dbba83.json";
        Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", credentialPath);
        _firestoreDb = FirestoreDb.Create("movieticketapp-d914f");
    }

[HttpPost("sync")]
public async Task<IActionResult> SyncUsers()
{
    var snapshot = await _firestoreDb.Collection("users").GetSnapshotAsync();

    foreach (var doc in snapshot.Documents)
    {
        var userId = doc.Id;
        var email = doc.ContainsField("email") ? doc.GetValue<string>("email") : null;
        var username = doc.ContainsField("username") ? doc.GetValue<string>("username") : null;
        var phone = doc.ContainsField("phone") ? doc.GetValue<string>("phone") : null;
        var role = doc.ContainsField("role") ? doc.GetValue<string>("role") : null;
        var createdAt = doc.ContainsField("created_at") ? doc.GetValue<DateTime>("created_at") : DateTime.UtcNow;
        var avatarUrl = doc.ContainsField("avatarUrl") ? doc.GetValue<string>("avatarUrl") : null;

        // Kiểm tra nếu UserId đã tồn tại
        if (!await _context.Users.AnyAsync(u => u.UserId == userId))
        {
            var user = new User
            {
                UserId = userId,
                Email = email,
                Username = username,
                Phone = phone,
                Role = role,
                CreatedAt = createdAt,
                AvatarUrl = avatarUrl
            };

            _context.Users.Add(user);
        }
    }

    await _context.SaveChangesAsync();
    return Ok(new { message = "Users synchronized successfully" });
}

}

}