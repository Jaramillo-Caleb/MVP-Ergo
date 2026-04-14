using Ergo.WorkSession.Domain.Entities;
using Ergo.WorkSession.Domain.Enums; 
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace Ergo.WorkSession.Infrastructure.Persistence
{
    public class SessionDbContext : DbContext
    {
        public DbSet<Domain.Entities.WorkSession> WorkSessions { get; set; }
        public DbSet<PostureEvent> PostureEvents { get; set; }
        public DbSet<ReferencePose> ReferencePoses { get; set; }
        public DbSet<PomodoroSettings> PomodoroSettings { get; set; }

        public SessionDbContext(DbContextOptions<SessionDbContext> options) : base(options) { }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<PomodoroSettings>(entity =>
            {
                entity.ToTable("PomodoroSettings");
                entity.HasKey(e => e.UserId);
                entity.Property(e => e.UserId).HasColumnName("user_id");
            });

            modelBuilder.Entity<Domain.Entities.WorkSession>(entity =>
            {
                entity.ToTable("WorkSessions");

                entity.HasKey(e => e.Id);
                entity.Property(e => e.Id).HasColumnName("id_session");

                entity.Property(e => e.UserId).HasColumnName("user_id").IsRequired();

                entity.Property(e => e.Mode)
                      .HasColumnName("mode")
                      .HasConversion<string>()
                      .IsRequired();

                entity.Property(e => e.ReferencePoseId)
                      .HasColumnName("id_reference_pose")
                      .IsRequired(false);

                entity.Property(e => e.StartTime).HasColumnName("start_time").IsRequired();
                entity.Property(e => e.EndTime).HasColumnName("end_time");
                entity.Property(e => e.ScoreAverage).HasColumnName("score_average");

                entity.HasMany(e => e.Events)
                      .WithOne()
                      .HasForeignKey(e => e.WorkSessionId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<PostureEvent>(entity =>
            {
                entity.ToTable("PostureEvents");

                entity.HasKey(e => e.Id);
                entity.Property(e => e.Id).HasColumnName("id_event");

                entity.Property(e => e.WorkSessionId).HasColumnName("id_session");

                entity.Property(e => e.Timestamp).HasColumnName("timestamp").IsRequired();
                entity.Property(e => e.Score).HasColumnName("score").IsRequired();
                entity.Property(e => e.IsAlert).HasColumnName("is_alert").IsRequired();
                entity.Property(e => e.Message).HasColumnName("message");
            });

            modelBuilder.Entity<ReferencePose>(entity =>
            {
                entity.ToTable("ReferencePoses");

                entity.HasKey(e => e.Id);
                entity.Property(e => e.Id).HasColumnName("id_reference_pose");

                entity.Property(e => e.UserId).HasColumnName("user_id").IsRequired();
                entity.Property(e => e.Alias).HasColumnName("alias");
                entity.Property(e => e.IsPersistent).HasColumnName("is_persistent").IsRequired();
                entity.Property(e => e.CreatedAt).HasColumnName("created_at").IsRequired();

                entity.Property(e => e.Vector)
                      .HasColumnName("vector_json")
                      .HasConversion(
                        v => JsonSerializer.Serialize(v, (JsonSerializerOptions?)null),
                        v => JsonSerializer.Deserialize<double[]>(v, (JsonSerializerOptions?)null) ?? Array.Empty<double>()
                      )
                      .Metadata.SetValueComparer(new Microsoft.EntityFrameworkCore.ChangeTracking.ValueComparer<double[]>(
                        (c1, c2) => c1.SequenceEqual(c2),
                        c => c.Aggregate(0, (a, v) => HashCode.Combine(a, v.GetHashCode())),
                        c => c.ToArray()));;
                });
        }
    }
}