using CallerCallee.ViewModels;
using CommunityToolkit.Mvvm.DependencyInjection;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using System;
using System.Linq;
using WinUI.TableView;

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
            TableView.FilterDescriptions.Add(new FilterDescription(string.Empty, ViewModel.Filter));
        }

        private void TabViewSelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (TableView.Columns.Count == 0) return;   

            var index = 0;
            if (sender is TabView tabView)
            {
                index = tabView.SelectedIndex;
            }

            TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.State))).First().Visibility = Visibility.Collapsed;
            TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.Entry))).First().Visibility = Visibility.Collapsed;
            TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.Id))).First().Width = new GridLength(100, GridUnitType.Star);
            switch (index)
            {
                case 0:
                    {
                        TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.Turns))).First().Visibility = Visibility.Visible;
                        TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.LastException))).First().Visibility = Visibility.Collapsed;
                        TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.Naive))).First().Visibility = Visibility.Collapsed;
                        TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.Enhanced))).First().Visibility = Visibility.Collapsed;
                        TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.RealDuration))).First().Visibility = Visibility.Collapsed;
                        TableView.ShowExportOptions = false;
                        break;
                    }
                case 1:
                    {
                        TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.Turns))).First().Visibility = Visibility.Visible;
                        TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.LastException))).First().Visibility = Visibility.Collapsed;
                        TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.Naive))).First().Visibility = Visibility.Visible;
                        TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.Enhanced))).First().Visibility = Visibility.Visible;
                        TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.RealDuration))).First().Visibility = Visibility.Visible;
                        TableView.ShowExportOptions = true;
                        break;
                    }
                default: 
                    {
                        TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.Turns))).First().Visibility = Visibility.Collapsed;
                        TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.LastException))).First().Visibility = Visibility.Visible;
                        TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.Naive))).First().Visibility = Visibility.Visible;
                        TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.Enhanced))).First().Visibility = Visibility.Visible;
                        TableView.Columns.Where(c => c.Header.ToString().Equals(nameof(DatasetViewModel.RealDuration))).First().Visibility = Visibility.Visible;
                        TableView.ShowExportOptions = true;
                        break;
                    }
            }

            ViewModel.ChangeTabCommand.Execute(index);

            TableView.RefreshFilter();
        }
    }
}
