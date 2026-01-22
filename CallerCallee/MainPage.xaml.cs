using Microsoft.UI.Xaml.Controls;
using Microsoft.Windows.Storage.Pickers;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;

namespace CallerCallee
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        private List<DatasetEntry>? Dataset;

        public ObservableCollection<DatasetEntry>? DataSourceVishing { get; set; }
        public ObservableCollection<DatasetEntry>? DataSourceNonVishing { get; set; }

        public MainPage()
        {
            this.InitializeComponent();
            this.DataContext = this;
        }

        private async void OpenFileAppBarButton_Click(object sender, Microsoft.UI.Xaml.RoutedEventArgs e)
        {
            if (sender is Button button)
            {
                //disable the button to avoid double-clicking
                button.IsEnabled = false;
                PlayAppBarButton.IsEnabled = false;

                var picker = new FileOpenPicker(button.XamlRoot.ContentIslandEnvironment.AppWindowId);
                picker.CommitButtonText = "Pick File";
                picker.FileTypeFilter.Add(".csv");
                picker.SuggestedStartLocation = PickerLocationId.DocumentsLibrary;
                picker.ViewMode = PickerViewMode.List;

                // Show the picker dialog window
                var file = await picker.PickSingleFileAsync();
                PickedSingleFileTextBlock.Text = file != null
                    ? "Picked: " + new FileInfo(file.Path).Name
                    : "No datasource selected.";

                try
                {
                    ProgressBar.Visibility = Microsoft.UI.Xaml.Visibility.Visible;
                    Dataset = DatasetEntry.LoadDatasetEntries(file.Path);
                }
                catch (Exception exception)
                {
                    var fileErrorDialog = new ContentDialog
                    {
                        Title = "Error while loading the dataset.",
                        Content = exception.Message,
                        CloseButtonText = "OK",
                        XamlRoot = this.XamlRoot,
                    };

                    ContentDialogResult result = await fileErrorDialog.ShowAsync();
                    return;
                } 
                finally
                {
                    ProgressBar.Visibility = Microsoft.UI.Xaml.Visibility.Collapsed;
                    //re-enable the button
                    button.IsEnabled = true;
                    PlayAppBarButton.IsEnabled = true;
                }

                DataSourceVishing = new ObservableCollection<DatasetEntry>(Dataset.TakeWhile(d => d.Kind == DatasetEntry.DatasetEntryKind.Vishing));
                DataSourceVishing = new ObservableCollection<DatasetEntry>(Dataset.TakeWhile(d => d.Kind == DatasetEntry.DatasetEntryKind.NotVishing));
            }
        }

        private void PlayAppBarButton_Click(object sender, Microsoft.UI.Xaml.RoutedEventArgs e)
        {
            //DataSourceVishing = GetData();
        }
    }
}
