const std = @import("std");

const max_input_size = 10 * 1024 * 1024; // 10 MiB

const all_days = [_]type{
    @import("./days/day01.zig"),
    @import("./days/day02.zig"),
    @import("./days/day05.zig"),
};

pub fn main() !void {
    var stdout = std.io.getStdOut().writer();
    var input_dir = try std.fs.cwd().openDir("./input", .{ .access_sub_paths = false });
    defer input_dir.close();

    var allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // No defer deinit, let OS free the memory

    const context = Context{
        .input_dir = &input_dir,
        .stdout = &stdout,
        .arena = &allocator,
    };

    inline for (all_days) |day| {
        try solveDay(day, &context);
    }
}

const Context = struct {
    input_dir: *std.fs.Dir,
    stdout: *std.fs.File.Writer,
    arena: *std.heap.ArenaAllocator,
};

fn solveDay(comptime day: type, ctx: *const Context) !void {
    defer _ = ctx.arena.reset(.retain_capacity);
    const allocator = ctx.arena.allocator();

    const day_name = @typeName(day)[5..];
    var day_file = try ctx.input_dir.openFile(day_name ++ ".txt", .{});
    defer day_file.close();

    const input = try day_file.reader().readAllAlloc(allocator, max_input_size);
    const solution1 = try day.solvePt1(allocator, input);
    const solution2 = try day.solvePt2(allocator, input);

    try ctx.stdout.print("{s}:\n\tpt1: {s}\n\tpt2: {s}\n", .{
        day_name,
        solution1,
        solution2,
    });
}
