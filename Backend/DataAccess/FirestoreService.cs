using Google.Cloud.Firestore;

namespace Backend.DataAccess
{
    public class FirestoreService
    {
        private FirestoreDb _firestoreDb;

public FirestoreService()
{
    // Đường dẫn mới tới file JSON
    string pathToCredentials = @"C:\Users\tranv\Downloads\DACN\movieticketapp-d914f-firebase-adminsdk-2m0f8-b1e688c750.json";
    
    // Thiết lập biến môi trường
    Environment.SetEnvironmentVariable("GOOGLE_APPLICATION_CREDENTIALS", pathToCredentials);

    // Tạo FirestoreDb
    _firestoreDb = FirestoreDb.Create("movieticketapp-d914f");
}


        public FirestoreDb GetFirestoreDb() => _firestoreDb;
    }
}

