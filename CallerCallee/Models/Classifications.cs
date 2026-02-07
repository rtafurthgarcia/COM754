using System;
using System.IO;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace CallerCallee.Models
{
    public record ClassificationResult
    {
        public Flag Flag { get; init; }
        public float Duration { get; init; }
    }

    public record Classifications
    {
        public Guid GroupId { get; init; }
        public string Id { get; init; }
        public float StartTimestamp { get; init; }
        public string TranscribedText { get; init; }
        public ClassificationResult NaiveClassification { get; init; }
        public ClassificationResult EnhancedClassification { get; init; }
        public Speaker Speaker { get; init; }

        private static readonly JsonSerializerOptions options = new()
        {
            PropertyNameCaseInsensitive = true
        };

        public record TurnOfConversationDto
        {
            [JsonPropertyName("id")]
            public int Id { get; init; }

            [JsonPropertyName("group_id")]
            public string GroupId { get; init; }

            [JsonPropertyName("speaker")]
            public string Speaker { get; init; }

            [JsonPropertyName("text")]
            public string Text { get; init; }

            [JsonPropertyName("naive_classification")]
            public JsonElement? NaiveClassification { get; init; }

            [JsonPropertyName("enhanced_classification")]
            public JsonElement? EnhancedClassification { get; init; }

            [JsonPropertyName("start_timestamp")]
            public double StartTimestamp { get; init; }
        }

        private record EndOfAnalysisDto
        {
            [JsonPropertyName("group_id")]
            public string GroupId { get; init; }
        }

        public static async Task<TurnOfConversationDto> FromJsonAsync(string json)
        {
            return await JsonSerializer.DeserializeAsync<TurnOfConversationDto>(
                new MemoryStream(Encoding.UTF8.GetBytes(json)),
                options
            ) ?? throw new JsonException("Failed to deserialize TurnOfConversation");
        }

        public static async Task<Guid> FromJsonGuidOnlyAsync(string json)
        {
            var dto = await JsonSerializer.DeserializeAsync<EndOfAnalysisDto>(
                new MemoryStream(Encoding.UTF8.GetBytes(json)),
                options
            ) ?? throw new JsonException("Failed to deserialize EndOfAnalysisDto");

            return Guid.Parse(dto.GroupId);
        }

        public static Classifications FromDto(TurnOfConversationDto dto, Speaker realSpeaker)
        {
            return (new Classifications
            {
                Id = dto.Id.ToString(),
                GroupId = Guid.Parse(dto.GroupId),
                TranscribedText = dto.Text,
                StartTimestamp = (float)dto.StartTimestamp,
                Speaker = realSpeaker,
                NaiveClassification = ParseClassification(dto.NaiveClassification, (float)dto.StartTimestamp),
                EnhancedClassification = ParseClassification(dto.EnhancedClassification, (float)dto.StartTimestamp)
            });
        }

        private static ClassificationResult ParseClassification(JsonElement? element, float startTimestamp)
        {
            if (element is null || element.Value.ValueKind == JsonValueKind.Null)
            {
                return new ClassificationResult
                {
                    Flag = Flag.Unknown,
                    Duration = 0
                };
            }

            var value = element.Value;

            if (value.ValueKind == JsonValueKind.Object)
            {
                Flag flag = Flag.Unknown;
                float duration = 0;

                if (value.TryGetProperty("answer", out var flagProp))
                {
                    flag = Enum.Parse<Flag>(flagProp.GetString()!, ignoreCase: true);
                }

                if (value.TryGetProperty("timestamp", out var durationProp))
                {
                    duration = durationProp.GetSingle() - startTimestamp;
                }

                return new ClassificationResult
                {
                    Flag = flag,
                    Duration = duration
                };
            }

            // Fallback
            return new ClassificationResult
            {
                Flag = Flag.Unknown,
                Duration = 0
            };
        }
    }
}
