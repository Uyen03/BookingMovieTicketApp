using Backend.DataAccess;
using Backend.Repositories;
using Backend.Services;
using Microsoft.EntityFrameworkCore;
using Backend.Extention;
using System.Text.Json.Serialization;
using Backend.Models;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSingleton<FirestoreService>();

// Cấu hình CORS để chấp nhận tất cả yêu cầu từ mọi nguồn gốc (nếu đang phát triển)
builder.Services.AddCors(options =>
{
    options.AddPolicy(name: "MovieTicketCorsPolicy", policy =>
    {
        policy.AllowAnyOrigin() // Cho phép tất cả nguồn gốc
              .AllowAnyHeader() // Cho phép tất cả header
              .AllowAnyMethod(); // Cho phép tất cả phương thức (GET, POST, PUT, DELETE, ...)
    });
});

// Đăng ký HttpClient
builder.Services.AddHttpClient();

// Cấu hình DbContext và chuỗi kết nối
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseMySql(
        Utils.DB_MYSQL,
        ServerVersion.AutoDetect(Utils.DB_MYSQL)));

// Đăng ký các dịch vụ và repository (Dependency Injection)
builder.Services.AddScoped<IMovieService, MovieRepository>();
builder.Services.AddScoped<ITheatreService, TheatreRepository>();
builder.Services.AddScoped<IShowtimeService, ShowtimeRepository>();
builder.Services.AddScoped<IActorService, ActorRepository>();
builder.Services.AddScoped<IScreenService, ScreenRepository>();
builder.Services.AddScoped<ISeatService, SeatRepository>();
builder.Services.AddScoped<ISnackPackageService, SnackPackageRepository>();
builder.Services.AddScoped<IBookingService, BookingRepository>();
builder.Services.AddTransient<IMomoService, MomoRepository>();
builder.Services.AddScoped<IRevenueService, RevenueRepository>();







// Thêm cấu hình JSON để xử lý chu kỳ tham chiếu và định dạng dữ liệu
builder.Services.AddControllersWithViews()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles; // Bỏ qua chu kỳ tham chiếu
        options.JsonSerializerOptions.PropertyNamingPolicy = null;
        options.JsonSerializerOptions.WriteIndented = true;
    });

// Thêm Swagger để hỗ trợ tài liệu API (tuỳ chọn)
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Tạo ứng dụng
var app = builder.Build();

// Cấu hình Middleware
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts(); // Bật HSTS (HTTP Strict Transport Security)
}
else
{
    app.UseDeveloperExceptionPage(); // Hiển thị lỗi chi tiết trong môi trường phát triển
    app.UseSwagger(); // Sử dụng Swagger UI
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Movie Ticket API v1");
        c.RoutePrefix = "swagger";
    });
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseCors("MovieTicketCorsPolicy"); // Áp dụng chính sách CORS
app.UseAuthorization();

// Cấu hình route mặc định
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

// Áp dụng route cho Web API
app.MapControllers();

app.Run();
