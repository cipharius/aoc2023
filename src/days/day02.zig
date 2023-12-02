const std = @import("std");

const CubeSet = struct {
    red: usize = 0,
    green: usize = 0,
    blue: usize = 0,
};

const cube_limits = CubeSet{
    .red = 12,
    .green = 13,
    .blue = 14,
};

pub fn solvePt1(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var sum: usize = 0;

    var line_iter = std.mem.tokenizeScalar(u8, input, '\n');
    line: while (line_iter.next()) |line| {
        var line_parser = std.fmt.Parser{ .buf = line };
        line_parser.pos += ("Game ").len;
        if (line_parser.pos >= line.len) return error.BadInput;

        const game_id = line_parser.number() orelse return error.BadInput;
        if (!line_parser.maybe(':') or !line_parser.maybe(' ')) return error.BadInput;

        const game = line[line_parser.pos..];

        var round_iter = std.mem.tokenizeSequence(u8, game, "; ");
        while (round_iter.next()) |round| {
            var cube_count = CubeSet{};

            var cube_iter = std.mem.tokenizeSequence(u8, round, ", ");
            while (cube_iter.next()) |cube| {
                var count_parser = std.fmt.Parser{ .buf = cube };
                const count = count_parser.number() orelse return error.BadInput;
                if (!count_parser.maybe(' ')) return error.BadInput;

                const color = cube[count_parser.pos..];

                if (std.mem.eql(u8, color, "red")) {
                    cube_count.red += count;
                } else if (std.mem.eql(u8, color, "green")) {
                    cube_count.green += count;
                } else if (std.mem.eql(u8, color, "blue")) {
                    cube_count.blue += count;
                } else {
                    return error.BadInput;
                }
            }

            if (cube_count.red > cube_limits.red or
                cube_count.green > cube_limits.green or
                cube_count.blue > cube_limits.blue)
            {
                continue :line;
            }
        }

        sum += game_id;
    }

    var result_buffer = try allocator.alloc(u8, 16);
    var io_stream = std.io.fixedBufferStream(result_buffer);
    try io_stream.writer().print("{}", .{sum});
    return io_stream.getWritten();
}

pub fn solvePt2(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var sum: usize = 0;

    var line_iter = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_iter.next()) |line| {
        const colon_idx = std.mem.indexOfScalar(u8, line, ':') orelse return error.BadInput;
        if (colon_idx + 2 >= line.len) return error.BadInput;

        const game = line[colon_idx + 2 ..];

        var cube_waterline = CubeSet{};

        var round_iter = std.mem.tokenizeSequence(u8, game, "; ");
        while (round_iter.next()) |round| {
            var cube_count = CubeSet{};

            var cube_iter = std.mem.tokenizeSequence(u8, round, ", ");
            while (cube_iter.next()) |cube| {
                var count_parser = std.fmt.Parser{ .buf = cube };
                const count = count_parser.number() orelse return error.BadInput;
                if (!count_parser.maybe(' ')) return error.BadInput;

                const color = cube[count_parser.pos..];

                if (std.mem.eql(u8, color, "red")) {
                    cube_count.red += count;
                } else if (std.mem.eql(u8, color, "green")) {
                    cube_count.green += count;
                } else if (std.mem.eql(u8, color, "blue")) {
                    cube_count.blue += count;
                } else {
                    return error.BadInput;
                }
            }

            cube_waterline.red = @max(cube_waterline.red, cube_count.red);
            cube_waterline.green = @max(cube_waterline.green, cube_count.green);
            cube_waterline.blue = @max(cube_waterline.blue, cube_count.blue);
        }

        sum += cube_waterline.red * cube_waterline.green * cube_waterline.blue;
    }

    var result_buffer = try allocator.alloc(u8, 16);
    var io_stream = std.io.fixedBufferStream(result_buffer);
    try io_stream.writer().print("{}", .{sum});
    return io_stream.getWritten();
}
