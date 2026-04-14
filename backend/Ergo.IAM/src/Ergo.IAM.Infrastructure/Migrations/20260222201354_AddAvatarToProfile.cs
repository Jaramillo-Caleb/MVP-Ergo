using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ergo.IAM.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddAvatarToProfile : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "AvatarPath",
                table: "UserProfiles",
                type: "TEXT",
                maxLength: 500,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AvatarPath",
                table: "UserProfiles");
        }
    }
}
