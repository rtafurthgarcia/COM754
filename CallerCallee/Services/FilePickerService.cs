using Microsoft.UI;
using Microsoft.UI.Xaml;
using Microsoft.Windows.Storage.Pickers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CallerCallee.Services
{
    public sealed class FilePickerService
    {
        public static async Task<PickFileResult> PickFileDialogAsync(WindowId id)
        {
            var picker = new FileOpenPicker(id)
            {
                CommitButtonText = "Pick File",
                SuggestedStartLocation = PickerLocationId.DocumentsLibrary,
                ViewMode = PickerViewMode.List
            };
            picker.FileTypeFilter.Add(".csv");

            // Show the picker dialog window
            return await picker.PickSingleFileAsync();
        }
    }
}
