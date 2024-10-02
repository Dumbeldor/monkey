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

    fn skipWhitespace(self: *Lexer) void {
        while (self.ch == ' ' or self.ch == '\t' or self.ch == '\n' or self.ch == '\r') {
            self.readChar();
        }
    }

    fn nextToken(self: *Lexer) token.Token {
        self.skipWhitespace();

        const ch = &[_]u8{self.ch};

        const t = switch (ch[0]) {
            '=' => token.Token.new(token.TokenEnum.ASSIGN, ch),
            '+' => token.Token.new(token.TokenEnum.PLUS, ch),
            ',' => token.Token.new(token.TokenEnum.COMMA, ch),
            ';' => token.Token.new(token.TokenEnum.SEMICOLON, ch),
            '(' => token.Token.new(token.TokenEnum.LPAREN, ch),
            ')' => token.Token.new(token.TokenEnum.RPAREN, ch),
            '{' => token.Token.new(token.TokenEnum.LBRACE, ch),
            '}' => token.Token.new(token.TokenEnum.RBRACE, ch),
            0 => token.Token.new(token.TokenEnum.EOF, ""),
            else => {
                if (utils.isLetter(ch[0])) {
                    const identifier = self.readIdentifier();
                    return token.Token.new(token.Token.keyword(identifier), identifier);
                }
                return token.Token.new(token.TokenEnum.ILLEGAL, ch);
            },
        };

        self.readChar();
        return t;
    }
};

test "TestNextTokenSimple" {
    const input = "=+(),;";
    const TestNextTokenStruct = struct {
        expectedType: token.TokenEnum,
        expectedLiteral: []const u8,
    };

    const tests = [_]TestNextTokenStruct{
        TestNextTokenStruct{ .expectedType = token.TokenEnum.ASSIGN, .expectedLiteral = "=" },
        TestNextTokenStruct{ .expectedType = token.TokenEnum.PLUS, .expectedLiteral = "+" },
        TestNextTokenStruct{ .expectedType = token.TokenEnum.LPAREN, .expectedLiteral = "(" },
        TestNextTokenStruct{ .expectedType = token.TokenEnum.RPAREN, .expectedLiteral = ")" },
        TestNextTokenStruct{ .expectedType = token.TokenEnum.COMMA, .expectedLiteral = "," },
        TestNextTokenStruct{ .expectedType = token.TokenEnum.SEMICOLON, .expectedLiteral = ";" },
        TestNextTokenStruct{ .expectedType = token.TokenEnum.EOF, .expectedLiteral = "" },
    };

    var lexer = Lexer.init(input);

    for (tests) |t| {
        const to = lexer.nextToken();
        //std.debug.print("{}|{s}\n{}|{s}\n---------\n", .{ t.expectedType, t.expectedLiteral, to.typet, to.literal });
        try std.testing.expect(t.expectedType == to.typet);
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
        expectedType: token.TokenEnum,
        expectedLiteral: []const u8,
    };
    const tests = [_]TestNextTokenStruct{
        // let five = 5;
        TestNextTokenStruct{ .expectedType = token.TokenEnum.LET, .expectedLiteral = "let" },
        TestNextTokenStruct{ .expectedType = token.TokenEnum.IDENT, .expectedLiteral = "five" },
        TestNextTokenStruct{ .expectedType = token.TokenEnum.ASSIGN, .expectedLiteral = "=" },
        TestNextTokenStruct{ .expectedType = token.TokenEnum.INT, .expectedLiteral = "5" },
        TestNextTokenStruct{ .expectedType = token.TokenEnum.SEMICOLON, .expectedLiteral = ";" },

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
        std.debug.print("{}|{s}\n{}|{s}\n---------\n", .{ t.expectedType, t.expectedLiteral, to.typet, to.literal });
        try std.testing.expect(t.expectedType == to.typet);
        try std.testing.expect(std.mem.eql(u8, t.expectedLiteral, to.literal));
    }
}
