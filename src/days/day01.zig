const std = @import("std");

pub fn solvePt1(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var sum: u64 = 0;

    var line_iter = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_iter.next()) |line| {
        const first_digit = blk: {
            var i: u8 = 0;
            while (i < line.len) : (i += 1) {
                const char = line[i];
                if ('0' <= char and char <= '9') break :blk char - '0';
            }
            break :blk 0;
        };

        const second_digit = blk: {
            var i: u8 = 0;
            while (i < line.len) : (i += 1) {
                const char = line[line.len - i - 1];
                if ('0' <= char and char <= '9') break :blk char - '0';
            }
            break :blk 0;
        };

        const number: u16 = 10 * first_digit + second_digit;
        sum += number;
    }

    var result_buffer = try allocator.alloc(u8, 16);
    var io_stream = std.io.fixedBufferStream(result_buffer);
    try io_stream.writer().print("{}", .{sum});
    return io_stream.getWritten();
}

const Digit = struct { name: []const u8, value: u8 };
const digits = [9]Digit{
    .{ .name = "one", .value = 1 },
    .{ .name = "two", .value = 2 },
    .{ .name = "three", .value = 3 },
    .{ .name = "four", .value = 4 },
    .{ .name = "five", .value = 5 },
    .{ .name = "six", .value = 6 },
    .{ .name = "seven", .value = 7 },
    .{ .name = "eight", .value = 8 },
    .{ .name = "nine", .value = 9 },
};

pub fn solvePt2(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var sum: u64 = 0;

    var line_iter = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_iter.next()) |line| {
        const first_digit = blk: {
            var i: usize = 0;
            while (i < line.len) : (i += 1) {
                if ('0' <= line[i] and line[i] <= '9') {
                    break :blk line[i] - '0';
                }

                inline for (digits) |digit| {
                    next_digit: {
                        if (i + digit.name.len >= line.len) break :next_digit;
                        var j: u4 = 0;
                        while (j < digit.name.len) : (j += 1) {
                            if (digit.name[j] != line[i + j]) {
                                break :next_digit;
                            }
                        }
                        break :blk digit.value;
                    }
                }
            }

            break :blk 0;
        };

        const second_digit = blk: {
            var i: usize = 0;
            while (i <= line.len) : (i += 1) {
                const i_rev = line.len - i - 1;
                if ('0' <= line[i_rev] and line[i_rev] <= '9') {
                    break :blk line[i_rev] - '0';
                }

                inline for (digits) |digit| {
                    next_digit: {
                        if (i + digit.name.len >= line.len) break :next_digit;
                        var j: u4 = 0;
                        while (j < digit.name.len) : (j += 1) {
                            const j_rev = digit.name.len - j - 1;
                            if (digit.name[j_rev] != line[i_rev - j]) {
                                break :next_digit;
                            }
                        }
                        break :blk digit.value;
                    }
                }
            }

            break :blk 0;
        };

        const number: u16 = 10 * first_digit + second_digit;
        sum += number;
    }

    var result_buffer = try allocator.alloc(u8, 16);
    var io_stream = std.io.fixedBufferStream(result_buffer);
    try io_stream.writer().print("{}", .{sum});
    return io_stream.getWritten();
}
