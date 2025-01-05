using Microsoft.AspNetCore.Mvc;
using Backend.Models;
using Google.Cloud.Firestore;

namespace Backend.Controllers
{
    public class AdminUserController : Controller
    {
        private readonly FirestoreDb _firestoreDb;

        public AdminUserController()
        {
            // Đặt đường dẫn tới file JSON
            var credentialPath = @"C:\Users\tranv\Downloads\DACN\movieticketapp-d914f-firebase-adminsdk-2m0f8-77e4dbba83.json";
            Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", credentialPath);

            // Tạo kết nối với Firestore
            _firestoreDb = FirestoreDb.Create("movieticketapp-d914f");
            Console.WriteLine($"Connected to Firestore project: {_firestoreDb.ProjectId}");
        }

        // GET: AdminUser
        public async Task<IActionResult> Index()
        {
            // Lấy danh sách người dùng từ Firestore
            var users = new List<User>();
            var snapshot = await _firestoreDb.Collection("users").GetSnapshotAsync();

            foreach (var document in snapshot.Documents)
            {
                // Lấy dữ liệu người dùng từ Firestore và map vào đối tượng User
                var user = new User
                {
                    UserId = document.Id, // Lấy Id của document
                    Username = document.GetValue<string>("username"), // Lấy trường username
                    Role = document.GetValue<string>("role"),         // Lấy trường role
                    Phone = document.GetValue<string>("phone"),       // Lấy trường phone
                    Email = document.GetValue<string>("email")        // Lấy trường email
                };
                users.Add(user);
            }

            return View(users);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(string id)
        {
            try
            {
                // Xóa tài liệu trong Firestore theo ID
                await _firestoreDb.Collection("users").Document(id).DeleteAsync();

                // Chuyển hướng về trang danh sách sau khi xóa thành công
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                // Xử lý lỗi nếu có
                Console.WriteLine($"Error deleting user: {ex.Message}");
                return RedirectToAction(nameof(Index), new { error = "Unable to delete user." });
            }
        }
    }
}
