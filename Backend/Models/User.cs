using Google.Cloud.Firestore;
using System;

namespace Backend.Models
{
    [FirestoreData]
    public class User
    {
        [FirestoreProperty("user_id")]
        public string UserId { get; set; }

        [FirestoreProperty("username")]
        public string Username { get; set; }

        [FirestoreProperty("email")]
        public string Email { get; set; }

        [FirestoreProperty("phone")]
        public string Phone { get; set; }

        [FirestoreProperty("role")]
        public string Role { get; set; }

        [FirestoreProperty("created_at")]
        public DateTime CreatedAt { get; set; }

        [FirestoreProperty("avatarUrl")]
        public string AvatarUrl { get; set; }
    }
}
