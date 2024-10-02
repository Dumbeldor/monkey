const std = @import("std");
const token = @import("token.zig");
const utils = @import("utils.zig");

const Lexer = struct {
    input: []const u8,
    position: u32 = 0,
    readPosition: u32 = 0,
    ch: u8 = 0,

    fn init(input: []const u8) Lexer {
        var l = Lexer{ .input = input };
        l.readChar();
        return l;
    }

    fn readChar(self: *Lexer) void {
        if (self.readPosition >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.readPosition];
        }

        self.position = self.readPosition;
        self.readPosition += 1;
    }

    fn readIdentifier(self: *Lexer) []const u8 {
        const position = self.position;
        while (utils.isLetter(self.ch)) {
            self.readChar();
        }

        return self.input[position..self.position];
    }

    fn nextToken(self: *Lexer) token.Token {
        const ch = &[_]u8{self.ch};

        const t = switch (ch[0]) {
            '=' => token.Token.new(token.ASSIGN, ch),
            '+' => token.Token.new(token.PLUS, ch),
            ',' => token.Token.new(token.COMMA, ch),
            ';' => token.Token.new(token.SEMICOLON, ch),
            '(' => token.Token.new(token.LPAREN, ch),
            ')' => token.Token.new(token.RPAREN, ch),
            '{' => token.Token.new(token.LBRACE, ch),
            '}' => token.Token.new(token.RBRACE, ch),
            0 => token.Token.new(token.EOF, ""),
            else => {
                if (utils.isLetter(ch[0])) {
                    const identifier = self.readIdentifier();
                    const t_identifier = token.Token.keyword(identifier) orelse "";
                    return token.Token.new(t_identifier, identifier);
                } else {
                    return token.Token.new(token.ILLEGAL, ch);
                }
            },
        };

        self.readChar();
        return t;
    }
};

test "TestNextTokenSimple" {
    const input = "=+(),;";
    const TestNextTokenStruct = struct {
        expectedType: token.TokenType,
        expectedLiteral: []const u8,
    };

    const tests = [_]TestNextTokenStruct{
        TestNextTokenStruct{ .expectedType = token.ASSIGN, .expectedLiteral = "=" },
        TestNextTokenStruct{ .expectedType = token.PLUS, .expectedLiteral = "+" },
        TestNextTokenStruct{ .expectedType = token.LPAREN, .expectedLiteral = "(" },
        TestNextTokenStruct{ .expectedType = token.RPAREN, .expectedLiteral = ")" },
        TestNextTokenStruct{ .expectedType = token.COMMA, .expectedLiteral = "," },
        TestNextTokenStruct{ .expectedType = token.SEMICOLON, .expectedLiteral = ";" },
        TestNextTokenStruct{ .expectedType = token.EOF, .expectedLiteral = "" },
    };

    var lexer = Lexer.init(input);

    for (tests) |t| {
        const to = lexer.nextToken();
        //std.debug.print("{s}|{s}\n{s}|{s}\n---------\n", .{ t.expectedType, t.expectedLiteral, to.typet, to.literal });
        try std.testing.expect(std.mem.eql(u8, t.expectedType, to.typet));
        try std.testing.expect(std.mem.eql(u8, t.expectedLiteral, to.literal));
    }
}

test "TestNextToken" {
    const input =
        \\let five = 5;
        \\let ten = 10;
        \\let add = fn(x, y) {
        \\  x + y;
        \\};
        \\
        \\let result = add(five, ten);
    ;

    //std.debug.print("{s}\n", .{input});

    const TestNextTokenStruct = struct {
        expectedType: token.TokenType,
        expectedLiteral: []const u8,
    };
    const tests = [_]TestNextTokenStruct{
        // let five = 5;
        TestNextTokenStruct{ .expectedType = token.LET, .expectedLiteral = "let" },
        TestNextTokenStruct{ .expectedType = token.IDENT, .expectedLiteral = "five" },
        TestNextTokenStruct{ .expectedType = token.ASSIGN, .expectedLiteral = "=" },
        TestNextTokenStruct{ .expectedType = token.INT, .expectedLiteral = "5" },
        TestNextTokenStruct{ .expectedType = token.SEMICOLON, .expectedLiteral = ";" },

        // let ten = 10;
        //TestNextTokenStruct{ .expectedType = token.LET, .expectedLiteral = "let" },
        //TestNextTokenStruct{ .expectedType = token.IDENT, .expectedLiteral = "ten" },
        //TestNextTokenStruct{ .expectedType = token.ASSIGN, .expectedLiteral = "=" },
        //TestNextTokenStruct{ .expectedType = token.INT, .expectedLiteral = "10" },
        //TestNextTokenStruct{ .expectedType = token.SEMICOLON, .expectedLiteral = ";" },
        //
        //// let add = fn(x, y) { x + y; };
        //TestNextTokenStruct{ .expectedType = token.LET, .expectedLiteral = "let" },
        //TestNextTokenStruct{ .expectedType = token.IDENT, .expectedLiteral = "add" },
        //TestNextTokenStruct{ .expectedType = token.ASSIGN, .expectedLiteral = "=" },
        //TestNextTokenStruct{ .expectedType = token.FUNCTION, .expectedLiteral = "fn" },
        //TestNextTokenStruct{ .expectedType = token.LPAREN, .expectedLiteral = "(" },
        //TestNextTokenStruct{ .expectedType = token.IDENT, .expectedLiteral = "x" },
        //TestNextTokenStruct{ .expectedType = token.COMMA, .expectedLiteral = "," },
        //TestNextTokenStruct{ .expectedType = token.IDENT, .expectedLiteral = "y" },
        //TestNextTokenStruct{ .expectedType = token.RPAREN, .expectedLiteral = ")" },
        //TestNextTokenStruct{ .expectedType = token.LBRACE, .expectedLiteral = "{" },
        //TestNextTokenStruct{ .expectedType = token.IDENT, .expectedLiteral = "x" },
        //TestNextTokenStruct{ .expectedType = token.PLUS, .expectedLiteral = "+" },
        //TestNextTokenStruct{ .expectedType = token.IDENT, .expectedLiteral = "y" },
        //TestNextTokenStruct{ .expectedType = token.SEMICOLON, .expectedLiteral = ";" },
        //TestNextTokenStruct{ .expectedType = token.RBRACE, .expectedLiteral = "}" },
        //TestNextTokenStruct{ .expectedType = token.SEMICOLON, .expectedLiteral = ";" },
        //
        //// let result = add(five, ten);
        //TestNextTokenStruct{ .expectedType = token.LET, .expectedLiteral = "let" },
        //TestNextTokenStruct{ .expectedType = token.IDENT, .expectedLiteral = "result" },
        //TestNextTokenStruct{ .expectedType = token.ASSIGN, .expectedLiteral = "=" },
        //TestNextTokenStruct{ .expectedType = token.IDENT, .expectedLiteral = "add" },
        //TestNextTokenStruct{ .expectedType = token.LPAREN, .expectedLiteral = "(" },
        //TestNextTokenStruct{ .expectedType = token.IDENT, .expectedLiteral = "five" },
        //TestNextTokenStruct{ .expectedType = token.COMMA, .expectedLiteral = "," },
        //TestNextTokenStruct{ .expectedType = token.IDENT, .expectedLiteral = "ten" },
        //TestNextTokenStruct{ .expectedType = token.RPAREN, .expectedLiteral = ")" },
        //TestNextTokenStruct{ .expectedType = token.SEMICOLON, .expectedLiteral = ";" },
    };

    var lexer = Lexer.init(input);

    for (tests) |t| {
        const to = lexer.nextToken();
        std.debug.print("{s}|{s}\n{s}|{s}\n---------\n", .{ t.expectedType, t.expectedLiteral, to.typet, to.literal });
        //try std.testing.expect(std.mem.eql(u8, t.expectedType, to.typet));
        //try std.testing.expect(std.mem.eql(u8, t.expectedLiteral, to.literal));
    }
}
