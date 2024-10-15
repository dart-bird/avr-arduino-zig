const uno = @import("uno.zig");
const regs = @import("atmega328p.zig").registers;

pub fn init(comptime baud: comptime_int) void {
    // Set baudrate
    regs.USART0.UBRR0.* = (uno.CPU_FREQ / (8 * baud)) - 1;

    // Default uart settings are 8n1, so no need to change them!
    regs.USART0.UCSR0A.modify(.{ .U2X0 = 1 });

    // Enable transmitter!
    regs.USART0.UCSR0B.modify(.{ .TXEN0 = 1 });
}

pub fn write(data: []const u8) void {
    for (data) |ch| {
        write_ch(ch);
    }

    // Wait till we are actually done sending
    while (regs.USART0.UCSR0A.read().TXC0 != 1) {}
}

pub fn write_ch(ch: u8) void {
    // Wait till the transmit buffer is empty
    while (regs.USART0.UCSR0A.read().UDRE0 != 1) {}

    regs.USART0.UDR0.* = ch;
}
pub fn format_int(val: u16, buffer: []u8) []u8 {
    // A simple function to convert an integer to a string.
    var i: usize = buffer.len;

    var temp = val;

    // Handle 0 case
    if (temp == 0) {
        buffer[0] = '0';
        return buffer[0..1];
    }

    // Extract digits from the end
    while (temp > 0 and i > 0) : (i -= 1) {
        buffer[i] = '0' + @as(u8, @intCast(temp % 10));
        temp /= 10;
    }

    // Return the slice with the valid characters
    return buffer[i..];
}
