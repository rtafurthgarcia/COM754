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
            ViewModel.CurrentTurns.CollectionChanged += CurrentTurnsCollectionChanged;
        }

        private void CurrentTurnsCollectionChanged(in ObservableCollections.NotifyCollectionChangedEventArgs<System.Collections.Generic.KeyValuePair<Models.DatasetEntry, Models.DatasetEntry>> e)
        {
            foreach (var item in e.NewItems)
            {
                MainTreeView.SelectedItems.Add(item);
            }
        }
    }
}
