const std = @import("std");
pub const TokenType = []const u8;

pub const Token = struct {
    typet: TokenType,
    literal: []const u8,

    pub fn new(t: TokenType, l: []const u8) Token {
        return Token{
            .typet = t,
            .literal = l,
        };
    }

    pub fn keyword(identifier: []const u8) ?[]const u8 {
        // todo dumbeldor: try to use comptime here?
        const map = std.StaticStringMap([]const u8).initComptime(.{
            .{ "let", LET },
            .{ "fn", FUNCTION },
        });
        return map.get(identifier);
    }
};

pub const ILLEGAL = "ILLEGAL";
pub const EOF = "EOF";
// Identifiers + literals
pub const IDENT = "IDENT";
pub const INT = "INT";
// Operators
pub const ASSIGN = "=";
pub const PLUS = "+";
// Delimiters
pub const COMMA = ",";
pub const SEMICOLON = ";";
pub const LPAREN = "(";
pub const RPAREN = ")";
pub const LBRACE = "{";
pub const RBRACE = "}";
// Keywords
pub const FUNCTION = "FUNCTION";
pub const LET = "LET";
