using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ergo.WorkSession.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
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
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PostureEvents");

            migrationBuilder.DropTable(
                name: "ReferencePoses");

            migrationBuilder.DropTable(
                name: "WorkSessions");
        }
    }
}
