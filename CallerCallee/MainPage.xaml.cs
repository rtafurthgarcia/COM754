using CallerCallee.ViewModels;
using CommunityToolkit.Mvvm.DependencyInjection;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using System;

namespace CallerCallee
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page 
    {
        public MainPageViewModel ViewModel => (MainPageViewModel)DataContext;
        public MainPage()
        {
            InitializeComponent();

            DataContext = Ioc.Default.GetRequiredService<MainPageViewModel>();
        }
    }
}
