using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace CallerCallee.Models
{
    // Odd structure I admit, but it was meant to be displayed originally in a tree-like component,
    // then I got too busy to refactorise it after dropping the idea.
    public record DatasetEntry
    {
        public string Id { get; set; }
        public Flag Is { get; set; }
        public Flag HumanClassification { get; set; }
        public string FilePath { get; set; }
        public EntryType Type { get; set; }
        public Queue<DatasetEntry> Children { get; set; }
        public List<Classifications> DetectionResults { get; set; } = [];
        public State State { get; set; } = State.Todo;
        public Exception Exception { get; set; }
        public string RealDuration { get; set; }
    }

    public static class DatasetEntryExporter
    {
        public static async Task ExportAsync(DatasetEntry entry)
        {
            if (!entry.Type.Equals(EntryType.Call))
                return;

            var path = GetOutputPath(entry);

            var snapshot = CreateSerializableSnapshot(entry);

            await using var stream = File.Create(path);
            await JsonSerializer.SerializeAsync(stream, snapshot, jsonOptions);
        }
        public sealed class SerializableDatasetEntry
        {
            public string Id { get; set; }
            public Flag Is { get; set; }
            public Flag HumanClassification { get; set; }
            public string FilePath { get; set; }
            public EntryType Type { get; set; }
            public List<SerializableDatasetEntry> Children { get; set; }
            public List<Classifications> DetectionResults { get; set; }
            public State State { get; set; }
            public string RealDuration { get; set; }
        }

        private static readonly JsonSerializerOptions jsonOptions = new()
        {
            WriteIndented = true,
            DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
            Converters =
            {
                new JsonStringEnumConverter()
            }
        };

        private static string GetOutputPath(DatasetEntry entry)
        {
            // Example: same folder, but .json instead of whatever input was
            var directory = Path.GetDirectoryName(entry.FilePath)!;
            var filename = Path.GetFileNameWithoutExtension(entry.FilePath);

            return Path.Combine(directory, $"{filename}.results.json");
        }

        private static SerializableDatasetEntry CreateSerializableSnapshot(DatasetEntry source)
        {
            return Clone(source);

            static SerializableDatasetEntry Clone(DatasetEntry entry)
            {
                return new SerializableDatasetEntry
                {
                    Id = entry.Id,
                    Is = entry.Is,
                    HumanClassification = entry.HumanClassification,
                    FilePath = entry.FilePath,
                    Type = entry.Type,
                    DetectionResults = entry.DetectionResults?.ToList(),
                    State = entry.State,
                    RealDuration = entry.RealDuration
                };
            }
        }
    }
}
