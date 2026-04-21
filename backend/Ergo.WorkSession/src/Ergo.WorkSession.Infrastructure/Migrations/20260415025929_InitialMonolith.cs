using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ergo.WorkSession.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class InitialMonolith : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PomodoroSettings",
                columns: table => new
                {
                    user_id = table.Column<Guid>(type: "TEXT", nullable: false),
                    WorkDuration = table.Column<int>(type: "INTEGER", nullable: false),
                    BreakDuration = table.Column<int>(type: "INTEGER", nullable: false),
                    AutoStart = table.Column<bool>(type: "INTEGER", nullable: false),
                    Repetitions = table.Column<int>(type: "INTEGER", nullable: false),
                    LastUpdated = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PomodoroSettings", x => x.user_id);
                });

            migrationBuilder.CreateTable(
                name: "ReferencePoses",
                columns: table => new
                {
                    id_reference_pose = table.Column<Guid>(type: "TEXT", nullable: false),
                    user_id = table.Column<Guid>(type: "TEXT", nullable: false),
                    alias = table.Column<string>(type: "TEXT", nullable: true),
                    vector_json = table.Column<string>(type: "TEXT", nullable: false),
                    is_persistent = table.Column<bool>(type: "INTEGER", nullable: false),
                    created_at = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ReferencePoses", x => x.id_reference_pose);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    FullName = table.Column<string>(type: "TEXT", nullable: false),
                    Email = table.Column<string>(type: "TEXT", nullable: false),
                    BirthDate = table.Column<DateTime>(type: "TEXT", nullable: false),
                    Gender = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false),
                    Carrera = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    Semestre = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "WorkSessions",
                columns: table => new
                {
                    id_session = table.Column<Guid>(type: "TEXT", nullable: false),
                    user_id = table.Column<Guid>(type: "TEXT", nullable: false),
                    mode = table.Column<string>(type: "TEXT", nullable: false),
                    id_reference_pose = table.Column<Guid>(type: "TEXT", nullable: true),
                    start_time = table.Column<DateTime>(type: "TEXT", nullable: false),
                    end_time = table.Column<DateTime>(type: "TEXT", nullable: true),
                    score_average = table.Column<double>(type: "REAL", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WorkSessions", x => x.id_session);
                    table.ForeignKey(
                        name: "FK_WorkSessions_Users_user_id",
                        column: x => x.user_id,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PostureEvents",
                columns: table => new
                {
                    id_event = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    id_session = table.Column<Guid>(type: "TEXT", nullable: false),
                    timestamp = table.Column<DateTime>(type: "TEXT", nullable: false),
                    score = table.Column<double>(type: "REAL", nullable: false),
                    is_alert = table.Column<bool>(type: "INTEGER", nullable: false),
                    message = table.Column<string>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PostureEvents", x => x.id_event);
                    table.ForeignKey(
                        name: "FK_PostureEvents_WorkSessions_id_session",
                        column: x => x.id_session,
                        principalTable: "WorkSessions",
                        principalColumn: "id_session",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PostureEvents_id_session",
                table: "PostureEvents",
                column: "id_session");

            migrationBuilder.CreateIndex(
                name: "IX_WorkSessions_user_id",
                table: "WorkSessions",
                column: "user_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PomodoroSettings");

            migrationBuilder.DropTable(
                name: "PostureEvents");

            migrationBuilder.DropTable(
                name: "ReferencePoses");

            migrationBuilder.DropTable(
                name: "WorkSessions");

            migrationBuilder.DropTable(
                name: "Users");
        }
    }
}
