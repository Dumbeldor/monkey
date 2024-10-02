const std = @import("std");

pub const TokenEnum = enum {
    ILLEGAL,
    EOF,
    // Identifiers + Literals
    IDENT,
    INT,
    // Operators
    ASSIGN, // =
    PLUS, // +
    MINUS, // -
    BANG, // !
    ASTERISK, // *
    SLASH, // /
    LT, // <
    GT, // >
    // Delimiters
    COMMA,
    SEMICOLON,
    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,
    // Keywords
    FUNCTION,
    LET,
};

pub const Token = struct {
    typet: TokenEnum,
    literal: []const u8,

    pub fn new(t: TokenEnum, l: []const u8) Token {
        return Token{
            .typet = t,
            .literal = l,
        };
    }

    pub fn keyword(identifier: []const u8) TokenEnum {
        // todo dumbeldor: try to use comptime here?
        const map = std.StaticStringMap(TokenEnum).initComptime(.{
            .{ "let", TokenEnum.LET },
            .{ "fn", TokenEnum.FUNCTION },
        });
        return map.get(identifier) orelse TokenEnum.IDENT;
    }
};

//pub const ILLEGAL = "ILLEGAL";
//pub const EOF = "EOF";
// Identifiers + literals
//pub const IDENT = "IDENT";
//pub const INT = "INT";
// Operators
//pub const ASSIGN = "=";
//pub const PLUS = "+";
// Delimiters
//pub const COMMA = ",";
//pub const SEMICOLON = ";";
//pub const LPAREN = "(";
//pub const RPAREN = ")";
//pub const LBRACE = "{";
//pub const RBRACE = "}";
// Keywords
//pub const FUNCTION = "FUNCTION";
//pub const LET = "LET";
