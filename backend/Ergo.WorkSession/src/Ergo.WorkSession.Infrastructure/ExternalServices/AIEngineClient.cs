using Ergo.WorkSession.Domain.Interfaces;
using Ergo.WorkSession.Domain.Types;
using System.Net.Http.Json;
using System.Text.Json;

namespace Ergo.WorkSession.Infrastructure.ExternalServices
{
    public class AIEngineClient : IAIEngineClient
    {
        private readonly HttpClient _httpClient;

        public AIEngineClient(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

        public async Task<CalibrationResult> CalibrateAsync(List<byte[]> images)
        {
            using var content = new MultipartFormDataContent();

            foreach (var imgBytes in images)
            {
                var imageContent = new ByteArrayContent(imgBytes);
                content.Add(imageContent, "images", "image.jpg");
            }

            var response = await _httpClient.PostAsync("/internal/calibration", content);
            response.EnsureSuccessStatusCode();

            var result = await response.Content.ReadFromJsonAsync<CalibrationResultResponse>();

            if (result == null) throw new InvalidOperationException("Respuesta vacía del motor de IA");

            return new CalibrationResult(result.reference_vector, result.message);
        }

        public async Task<ComparisonResult> CompareAsync(byte[] image, double[] referenceVector)
        {
            using var content = new MultipartFormDataContent();

            var imageContent = new ByteArrayContent(image);
            content.Add(imageContent, "image", "capture.jpg");

            var vectorJson = JsonSerializer.Serialize(referenceVector);
            content.Add(new StringContent(vectorJson), "reference_vector");

            var response = await _httpClient.PostAsync("/internal/compare", content);
            response.EnsureSuccessStatusCode();

            var result = await response.Content.ReadFromJsonAsync<ComparisonResultResponse>();

            if (result == null) throw new InvalidOperationException("Respuesta vacía del motor de IA");

            return new ComparisonResult(result.score, result.is_correct, result.message ?? "");
        }

        private record CalibrationResultResponse(double[] reference_vector, string message);
        private record ComparisonResultResponse(double score, bool is_correct, string? message);
    }
}