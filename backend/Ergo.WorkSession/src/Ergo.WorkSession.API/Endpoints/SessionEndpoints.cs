using Ergo.WorkSession.Application.DTOs;
using Ergo.WorkSession.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Ergo.WorkSession.Domain.Entities;

namespace Ergo.WorkSession.API.Endpoints
{
    public static class SessionEndpoints
    {
        public static void MapSessionEndpoints(this IEndpointRouteBuilder app)
        {
            var group = app.MapGroup("/api/work-session").WithTags("WorkSession");

            group.MapGet("/postures/{userId}", async (
                Guid userId,
                ISessionOrchestrator orchestrator) =>
            {
                var result = await orchestrator.GetSavedPosturesAsync(userId);
                return Results.Ok(result);
            });

            group.MapPost("/postures", async (
                [FromBody] CreatePostureRequest request,
                ISessionOrchestrator orchestrator,
                [FromHeader(Name = "X-User-Id")] Guid? userIdHeader) =>
            {
                var finalRequest = request with { UserId = userIdHeader ?? request.UserId };

                var result = await orchestrator.CreatePostureProfileAsync(finalRequest);
                return Results.Ok(result);
            });

            group.MapDelete("/postures/{postureId}", async (
                Guid postureId,
                ISessionOrchestrator orchestrator,
                [FromHeader(Name = "X-User-Id")] Guid? userIdHeader) =>
            {
                var userId = userIdHeader ?? Guid.Empty;
                await orchestrator.DeletePostureAsync(postureId, userId);
                return Results.NoContent();
            });

            group.MapPost("/calibration/calculate", async (
                HttpRequest request,
                ISessionOrchestrator orchestrator) =>
            {
                if (!request.HasFormContentType)
                    return Results.BadRequest("Se espera multipart/form-data");

                var form = await request.ReadFormAsync();

                if (form.Files.Count == 0)
                    return Results.BadRequest("No se enviaron imágenes.");

                var imagesBytes = new List<byte[]>();
                foreach (var file in form.Files)
                {
                    using var ms = new MemoryStream();
                    await file.CopyToAsync(ms);
                    imagesBytes.Add(ms.ToArray());
                }

                try
                {
                    var result = await orchestrator.ComputeCalibrationAsync(imagesBytes);
                    return Results.Ok(result);
                }
                catch (Exception ex)
                {
                    return Results.Problem(ex.Message);
                }
            })
            .DisableAntiforgery();

            group.MapPost("/session/start", async (
                [FromBody] StartSessionRequest request,
                ISessionOrchestrator orchestrator,
                [FromHeader(Name = "X-User-Id")] Guid? userIdHeader) =>
            {
                var finalRequest = request with { UserId = userIdHeader ?? request.UserId };

                try
                {
 
                    var result = await orchestrator.StartSessionAsync(finalRequest);
                    return Results.Ok(result);
                }
                catch (InvalidOperationException ex)
                {
                    return Results.BadRequest(ex.Message); 
                }
                catch (Exception ex)
                {
                    return Results.Problem(ex.Message);
                }
            });

            group.MapPost("/session/{sessionId}/monitor", async (
                Guid sessionId,
                HttpRequest request,
                ISessionOrchestrator orchestrator) =>
            {
                if (!request.HasFormContentType)
                    return Results.BadRequest("Se espera multipart/form-data");

                var form = await request.ReadFormAsync();
                var file = form.Files["image"];

                if (file == null)
                    return Results.BadRequest("Imagen requerida (key='image').");

                using var ms = new MemoryStream();
                await file.CopyToAsync(ms);
                var imageBytes = ms.ToArray();

                try
                {
                    var result = await orchestrator.ProcessFrameAsync(sessionId, imageBytes);
                    return Results.Ok(result);
                }
                catch (KeyNotFoundException)
                {
                    return Results.NotFound("La sesión no existe o finalizó.");
                }
                catch (InvalidOperationException) 
                {
                    return Results.Conflict("Error de estado en la sesión.");
                }
            })
            .DisableAntiforgery();

            group.MapPost("/session/{sessionId}/pause", async (
                Guid sessionId,
                ISessionOrchestrator orchestrator) =>
            {
                await orchestrator.PauseSessionAsync(sessionId);
                return Results.Ok(new { status = "Paused" });
            });

            group.MapPost("/session/{sessionId}/resume", async (
                Guid sessionId,
                ISessionOrchestrator orchestrator) =>
            {
                await orchestrator.ResumeSessionAsync(sessionId);
                return Results.Ok(new { status = "Running" });
            });

            group.MapPost("/session/{sessionId}/stop", async (
                Guid sessionId,
                ISessionOrchestrator orchestrator) =>
            {
                var summary = await orchestrator.StopSessionAsync(sessionId);
                return Results.Ok(summary);
            });

            group.MapGet("/settings/{userId}", async (
                Guid userId,
                ISessionOrchestrator orchestrator) =>
            {
                var settings = await orchestrator.GetPomodoroSettingsAsync(userId);
                if (settings == null)
                {
                    return Results.Ok(new PomodoroSettings { UserId = userId });
                }
                return Results.Ok(settings);
            });

            group.MapPost("/settings", async (
                [FromBody] PomodoroSettingsRequest request,
                ISessionOrchestrator orchestrator,
                [FromHeader(Name = "X-User-Id")] Guid? userIdHeader) =>
            {
                var userId = userIdHeader ?? request.UserId;
                var finalRequest = request with { UserId = userId };
                await orchestrator.UpdatePomodoroSettingsAsync(finalRequest);
                return Results.NoContent();
            });
        }
    }
}