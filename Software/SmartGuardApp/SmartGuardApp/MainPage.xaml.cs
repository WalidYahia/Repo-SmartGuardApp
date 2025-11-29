using SmartGuardApp.Models;
using SmartGuardApp.Services;

namespace SmartGuardApp
{
    public partial class MainPage : ContentPage
    {
        private readonly ApiService _apiService;
        private bool _isLoading = false;

        public MainPage()
        {
            InitializeComponent();
            
            // Get ApiService from service provider
            // Will be set in OnAppearing when Handler is available
            _apiService = new ApiService(new HttpClient());
        }

        protected override void OnAppearing()
        {
            base.OnAppearing();
            
            // Try to get service from service provider
            if (Handler?.MauiContext?.Services != null)
            {
                var service = Handler.MauiContext.Services.GetService<ApiService>();
                if (service != null)
                {
                    // Use the registered service instance if available
                    // For now, we'll use the direct instance but this shows how to get it from DI
                }
            }
            
            // Reload units when page appears
            _ = LoadUnitsAsync();
        }

        private async Task LoadUnitsAsync()
        {
            if (_isLoading) return;

            _isLoading = true;
            LoadingIndicator.IsRunning = true;
            LoadingIndicator.IsVisible = true;
            UnitsCollectionView.IsVisible = false;
            ErrorLabel.IsVisible = false;
            ErrorLabel.Text = string.Empty;

            try
            {
                var units = await _apiService.LoadAllUnitsAsync();
                
                if (units != null && units.Count > 0)
                {
                    // Update the collection view with loaded units
                    UnitsCollectionView.ItemsSource = units;
                    UnitsCollectionView.IsVisible = true;
                }
                else
                {
                    UnitsCollectionView.ItemsSource = null;
                    UnitsCollectionView.IsVisible = true; // Show empty view
                }

#if DEBUG
                System.Diagnostics.Debug.WriteLine($"Loaded {units?.Count ?? 0} units");
#endif
            }
            catch (Exception ex)
            {
                ErrorLabel.Text = $"Error loading units: {ex.Message}";
                ErrorLabel.IsVisible = true;
                UnitsCollectionView.IsVisible = false;
#if DEBUG
                System.Diagnostics.Debug.WriteLine($"Error loading units: {ex.Message}");
#endif
            }
            finally
            {
                _isLoading = false;
                LoadingIndicator.IsRunning = false;
                LoadingIndicator.IsVisible = false;
                RefreshView.IsRefreshing = false;
            }
        }

        private async void OnRefreshClicked(object? sender, EventArgs e)
        {
            await LoadUnitsAsync();
        }

        private async void OnRefreshing(object? sender, EventArgs e)
        {
            await LoadUnitsAsync();
        }
    }
}
