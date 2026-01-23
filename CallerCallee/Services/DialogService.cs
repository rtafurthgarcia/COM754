using Microsoft.UI;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Microsoft.Windows.Storage.Pickers;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CallerCallee.Services
{
    public sealed class DialogService
    {
        public Task ShowMessageDialogAsync(XamlRoot root, string title, string message)
        {
            ContentDialog dialog = new();
            dialog.Title = title;   
            dialog.CloseButtonText = "OK";
            dialog.DefaultButton = ContentDialogButton.Close;
            dialog.Content = message;
            dialog.XamlRoot = root;

            return dialog.ShowAsync().AsTask();
        }
    }
}
