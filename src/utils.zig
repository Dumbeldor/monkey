const std = @import("std");

pub fn isLetter(c: u8) bool {
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or c == '_';
}

pub fn isNumber(c: u8) bool {
    return std.ascii.isDigit(c);
}

pub fn isWhitespace(c: u8) bool {
    return std.ascii.isWhitespace(c);
}
