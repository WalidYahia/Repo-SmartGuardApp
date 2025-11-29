using Microsoft.Extensions.Logging;
using Microsoft.Extensions.DependencyInjection;
using SmartGuardApp.Services;

namespace SmartGuardApp
{
    public static class MauiProgram
    {
        public static MauiApp CreateMauiApp()
        {
            var builder = MauiApp.CreateBuilder();
            builder
                .UseMauiApp<App>()
                .ConfigureFonts(fonts =>
                {
                    fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
                    fonts.AddFont("OpenSans-Semibold.ttf", "OpenSansSemibold");
                });

#if DEBUG
    		builder.Logging.AddDebug();
#endif

            // Register API Service with HttpClient
            builder.Services.AddSingleton<ApiService>(sp =>
            {
                var httpClient = new HttpClient();
                return new ApiService(httpClient);
            });

            return builder.Build();
        }
    }
}
