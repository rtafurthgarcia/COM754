using CallerCallee.Services;
using CallerCallee.ViewModels;
using CommunityToolkit.Mvvm.DependencyInjection;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.UI.Dispatching;
using Microsoft.UI.Xaml;
using Microsoft.Windows.AppNotifications;
using Microsoft.Windows.AppNotifications.Builder;
using System;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;

// To learn more about WinUI, the WinUI project structure,
// and more about our project templates, see: http://aka.ms/winui-project-info.

namespace CallerCallee
{
    /// <summary>
    /// Provides application-specific behavior to supplement the default Application class.
    /// </summary>
    public partial class App : Application
    {
        private Window _window;

        /// <summary>
        /// Initializes the singleton application object.  This is the first line of authored code
        /// executed, and as such is the logical equivalent of main() or WinMain().
        /// </summary>
        public App()
        {
            InitializeComponent();

            TaskScheduler.UnobservedTaskException += TaskSchedulerUnobservedTaskException;

            UnhandledException += OnAppUnhandledException;
        }

        private void OnAppUnhandledException(object sender, Microsoft.UI.Xaml.UnhandledExceptionEventArgs e)
        {
            AppNotification notification = new AppNotificationBuilder()
                    .AddText("Unhandled exception: simulation interrupted")
                    .AddText(e.Message)
                    .SetAppLogoOverride(new Uri("ms-appx:///Assets/error-96.png"), AppNotificationImageCrop.Default)
                    .SetAudioEvent(AppNotificationSoundEvent.Alarm10, AppNotificationAudioLooping.Loop)
                    .SetTimeStamp(DateTime.Now)
                    .BuildNotification();

            AppNotificationManager.Default.Show(notification);

            File.WriteAllText(
               "crash.log",
               e.Exception.StackTrace
           );
        }

        private void TaskSchedulerUnobservedTaskException(object sender, UnobservedTaskExceptionEventArgs e)
        {
            AppNotification notification = new AppNotificationBuilder()
                    .AddText("Unobserved Task Exception: simulation interrupted")
                    .AddText(e.Exception.ToString())
                    .SetAppLogoOverride(new Uri("ms-appx:///Assets/error-96.png"), AppNotificationImageCrop.Default)
                    .SetAudioEvent(AppNotificationSoundEvent.Alarm10, AppNotificationAudioLooping.Loop)
                    .SetTimeStamp(DateTime.Now)
                    .BuildNotification();

            AppNotificationManager.Default.Show(notification);

            File.WriteAllText(
               "crash-ts.log",
               e.Exception.StackTrace
           );
        }

        /// <summary>
        /// Invoked when the application is launched.
        /// </summary>
        /// <param name="args">Details about the launch request and process.</param>
        protected override void OnLaunched(Microsoft.UI.Xaml.LaunchActivatedEventArgs args)
        {
            // Register services
            Ioc.Default.ConfigureServices(
                new ServiceCollection()
                // services
                .AddSingleton<AuthenticationService>()
                .AddSingleton<DatasetService>()
                .AddSingleton<CallerCalleeService>()
                .AddSingleton<SettingsService>()
                .AddSingleton<AudioService>()
                .AddSingleton<DetectionService>()

                // models
                .AddTransient<MainPageViewModel>()
                .BuildServiceProvider());

            _window = new MainWindow();
            _window.Activate();
        }
    }
}
