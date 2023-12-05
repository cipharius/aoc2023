const std = @import("std");

const IdMap = struct { from: usize, to: usize, len: usize };
const IdMaps = struct {
    seedToSoil: []IdMap = &.{},
    soilToFertilizer: []IdMap = &.{},
    fertilizerToWater: []IdMap = &.{},
    waterToLight: []IdMap = &.{},
    lightToTemperature: []IdMap = &.{},
    temperatureToHumidity: []IdMap = &.{},
    humidityToLocation: []IdMap = &.{},
};

fn lookup(maps: []const IdMap, id: usize) usize {
    for (maps) |map| {
        if (id >= map.from and id - map.from < map.len) {
            return map.to + (id - map.from);
        }
    }
    return id;
}

pub fn solvePt1(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var section_iterator = std.mem.tokenizeSequence(u8, input, "\n\n");

    const seed_section = section_iterator.next() orelse return error.BadInput;
    const seeds_str = seed_section[("seeds: ").len..];

    var id_maps = IdMaps{};
    while (section_iterator.next()) |section| {
        const n_entries = std.mem.count(u8, section, "\n");
        if (n_entries == 0) continue;

        var line_iterator = std.mem.tokenizeScalar(u8, section, '\n');
        const header_line = line_iterator.next() orelse return error.BadInput;

        const map_slice: *[]IdMap =
            if (std.mem.startsWith(u8, header_line, "seed-to-soil"))
            &id_maps.seedToSoil
        else if (std.mem.startsWith(u8, header_line, "soil-to-fertilizer"))
            &id_maps.soilToFertilizer
        else if (std.mem.startsWith(u8, header_line, "fertilizer-to-water"))
            &id_maps.fertilizerToWater
        else if (std.mem.startsWith(u8, header_line, "water-to-light"))
            &id_maps.waterToLight
        else if (std.mem.startsWith(u8, header_line, "light-to-temperature"))
            &id_maps.lightToTemperature
        else if (std.mem.startsWith(u8, header_line, "temperature-to-humidity"))
            &id_maps.temperatureToHumidity
        else if (std.mem.startsWith(u8, header_line, "humidity-to-location"))
            &id_maps.humidityToLocation
        else
            return error.BadInput;

        map_slice.* = try allocator.alloc(IdMap, n_entries);

        var i: usize = 0;
        while (line_iterator.next()) |line| {
            var parser = std.fmt.Parser{ .buf = line };
            const toId = parser.number() orelse return error.BadInput;
            if (!parser.maybe(' ')) return error.BadInput;
            const fromId = parser.number() orelse return error.BadInput;
            if (!parser.maybe(' ')) return error.BadInput;
            const idRange = parser.number() orelse return error.BadInput;
            map_slice.*[i] = IdMap{ .from = fromId, .to = toId, .len = idRange };
            i += 1;
        }
    }

    var lowest_location: ?usize = null;
    var seed_iterator = std.mem.tokenizeScalar(u8, seeds_str, ' ');
    while (seed_iterator.next()) |seed_str| {
        var parser = std.fmt.Parser{ .buf = seed_str };
        const seed = parser.number() orelse return error.BadInput;
        const soil = lookup(id_maps.seedToSoil, seed);
        const fertilizer = lookup(id_maps.soilToFertilizer, soil);
        const water = lookup(id_maps.fertilizerToWater, fertilizer);
        const light = lookup(id_maps.waterToLight, water);
        const temperature = lookup(id_maps.lightToTemperature, light);
        const humidity = lookup(id_maps.temperatureToHumidity, temperature);
        const location = lookup(id_maps.humidityToLocation, humidity);

        if (lowest_location) |lowest_loc| {
            lowest_location = @min(location, lowest_loc);
        } else {
            lowest_location = location;
        }
    }

    var result_buffer = try allocator.alloc(u8, 16);
    var io_stream = std.io.fixedBufferStream(result_buffer);
    try io_stream.writer().print("{}", .{lowest_location orelse return error.NoResult});
    return io_stream.getWritten();
}

const IdRange = struct {
    id: usize,
    len: usize,
};

pub const LookupIterator = struct {
    range: IdRange,
    maps: []const IdMap,

    pub fn next(it: *LookupIterator) ?IdRange {
        if (it.range.len == 0) return null;

        for (it.maps) |map| {
            if (it.range.id >= map.from and it.range.id - map.from < map.len) {
                const remainder = map.len - (it.range.id - map.from);
                const new_len = @min(it.range.len, remainder);
                const new_id = map.to + (it.range.id - map.from);

                it.range = IdRange{
                    .id = it.range.id + new_len,
                    .len = it.range.len - new_len,
                };
                return IdRange{ .id = new_id, .len = new_len };
            }
        }

        const original = it.range;
        it.range = IdRange{ .id = undefined, .len = 0 };
        return original;
    }
};

pub fn solvePt2(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    var section_iterator = std.mem.tokenizeSequence(u8, input, "\n\n");

    const seed_section = section_iterator.next() orelse return error.BadInput;
    const seeds_str = seed_section[("seeds: ").len..];

    var id_maps = IdMaps{};
    while (section_iterator.next()) |section| {
        const n_entries = std.mem.count(u8, section, "\n");
        if (n_entries == 0) continue;

        var line_iterator = std.mem.tokenizeScalar(u8, section, '\n');
        const header_line = line_iterator.next() orelse return error.BadInput;

        const map_slice: *[]IdMap =
            if (std.mem.startsWith(u8, header_line, "seed-to-soil"))
            &id_maps.seedToSoil
        else if (std.mem.startsWith(u8, header_line, "soil-to-fertilizer"))
            &id_maps.soilToFertilizer
        else if (std.mem.startsWith(u8, header_line, "fertilizer-to-water"))
            &id_maps.fertilizerToWater
        else if (std.mem.startsWith(u8, header_line, "water-to-light"))
            &id_maps.waterToLight
        else if (std.mem.startsWith(u8, header_line, "light-to-temperature"))
            &id_maps.lightToTemperature
        else if (std.mem.startsWith(u8, header_line, "temperature-to-humidity"))
            &id_maps.temperatureToHumidity
        else if (std.mem.startsWith(u8, header_line, "humidity-to-location"))
            &id_maps.humidityToLocation
        else
            return error.BadInput;

        map_slice.* = try allocator.alloc(IdMap, n_entries);

        var i: usize = 0;
        while (line_iterator.next()) |line| {
            var parser = std.fmt.Parser{ .buf = line };
            const toId = parser.number() orelse return error.BadInput;
            if (!parser.maybe(' ')) return error.BadInput;
            const fromId = parser.number() orelse return error.BadInput;
            if (!parser.maybe(' ')) return error.BadInput;
            const idRange = parser.number() orelse return error.BadInput;
            map_slice.*[i] = IdMap{ .from = fromId, .to = toId, .len = idRange };
            i += 1;
        }
    }

    var lowest_location: ?usize = null;
    var seed_iterator = std.mem.tokenizeScalar(u8, seeds_str, ' ');
    while (seed_iterator.next()) |seed_str| {
        var parser = std.fmt.Parser{ .buf = seed_str };
        const seed_id = parser.number() orelse return error.BadInput;
        const next_seed_str = seed_iterator.next() orelse return error.BadInput;
        parser = std.fmt.Parser{ .buf = next_seed_str };
        const seed_id_len = parser.number() orelse return error.BadInput;
        const seed_range = IdRange{ .id = seed_id, .len = seed_id_len };

        // Here we go...
        var soil_iterator = LookupIterator{
            .maps = id_maps.seedToSoil,
            .range = seed_range,
        };
        while (soil_iterator.next()) |soil_range| {
            var fertilizer_iterator = LookupIterator{
                .maps = id_maps.soilToFertilizer,
                .range = soil_range,
            };
            while (fertilizer_iterator.next()) |fertilizer_range| {
                var water_iterator = LookupIterator{
                    .maps = id_maps.fertilizerToWater,
                    .range = fertilizer_range,
                };
                while (water_iterator.next()) |water_range| {
                    var light_iterator = LookupIterator{
                        .maps = id_maps.waterToLight,
                        .range = water_range,
                    };
                    while (light_iterator.next()) |light_range| {
                        var temperature_iterator = LookupIterator{
                            .maps = id_maps.lightToTemperature,
                            .range = light_range,
                        };
                        while (temperature_iterator.next()) |temperature_range| {
                            var humidity_iterator = LookupIterator{
                                .maps = id_maps.temperatureToHumidity,
                                .range = temperature_range,
                            };
                            while (humidity_iterator.next()) |humidity_range| {
                                var location_iterator = LookupIterator{
                                    .maps = id_maps.humidityToLocation,
                                    .range = humidity_range,
                                };
                                while (location_iterator.next()) |location_range| {
                                    if (lowest_location) |lowest_loc| {
                                        lowest_location = @min(location_range.id, lowest_loc);
                                    } else {
                                        lowest_location = location_range.id;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    var result_buffer = try allocator.alloc(u8, 16);
    var io_stream = std.io.fixedBufferStream(result_buffer);
    try io_stream.writer().print("{}", .{lowest_location orelse return error.NoResult});
    return io_stream.getWritten();
}
