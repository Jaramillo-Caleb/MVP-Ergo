using Google.Apis.Auth;
using Microsoft.Extensions.Configuration;
using System.Net.Http;
using System.Net.Http.Json;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Text.Json;
using System.Net.Http.Headers;
using System.Linq;
using Ergo.IAM.Core.Interfaces;
using Ergo.IAM.Core.DTOs;

namespace Ergo.IAM.Infrastructure.Services
{
    public class SocialAuthService : ISocialAuthService
    {
        private readonly IConfiguration _config;
        private readonly IHttpClientFactory _httpClientFactory;

        public SocialAuthService(IConfiguration config, IHttpClientFactory httpClientFactory)
        {
            _config = config;
            _httpClientFactory = httpClientFactory;
        }

        public async Task<(string Email, string ExternalId, string FullName)> VerifyGoogleToken(string idToken)
        {
            var settings = new GoogleJsonWebSignature.ValidationSettings()
            {
                Audience = new[] { _config["Authentication:Google:ClientId"] }
            };

            var payload = await GoogleJsonWebSignature.ValidateAsync(idToken, settings);
            return (payload.Email, payload.Subject, payload.Name);
        }

        public async Task<(string Email, string ExternalId, string FullName)> VerifyGitHubCode(string code)
        {
            var client = _httpClientFactory.CreateClient();

            var tokenRequest = new HttpRequestMessage(HttpMethod.Post, "https://github.com/login/oauth/access_token");
            tokenRequest.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            tokenRequest.Content = new FormUrlEncodedContent(new Dictionary<string, string>
            {
                ["client_id"] = _config["Authentication:GitHub:ClientId"]!,
                ["client_secret"] = _config["Authentication:GitHub:ClientSecret"]!,
                ["code"] = code
            });

            var tokenResponse = await client.SendAsync(tokenRequest);
            var tokenContent = await tokenResponse.Content.ReadFromJsonAsync<JsonElement>();
            
            if (!tokenContent.TryGetProperty("access_token", out var accessTokenProp))
                throw new Exception("No se pudo obtener el token de GitHub");

            var accessToken = accessTokenProp.GetString();

            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
            client.DefaultRequestHeaders.UserAgent.ParseAdd("Ergo-App");
            
            var userResponse = await client.GetAsync("https://api.github.com/user");
            var userData = await userResponse.Content.ReadFromJsonAsync<JsonElement>();
            string externalId = userData.GetProperty("id").GetRawText();
            string fullName = userData.TryGetProperty("name", out var nameProp) ? nameProp.GetString() ?? "" : "";

            var emailsResponse = await client.GetAsync("https://api.github.com/user/emails");
            var emails = await emailsResponse.Content.ReadFromJsonAsync<List<GitHubEmail>>();
            var bestEmail = emails?.FirstOrDefault(e => e.Primary && e.Verified) ?? emails?.FirstOrDefault(e => e.Verified);

            if (bestEmail == null || string.IsNullOrEmpty(bestEmail.Email))
            {
                throw new Exception("No se pudo obtener el email de GitHub");
            }

            return (bestEmail.Email, externalId, fullName);
        }
    }
}