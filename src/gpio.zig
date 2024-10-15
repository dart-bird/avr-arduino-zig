const regs = @import("atmega328p.zig").registers;

/// For now supports PORTB and PORTD
pub fn digitalInit(comptime pin: u8, comptime dir: enum { in, out }) void {
    if (pin >= 8 and pin <= 13) {
        const actual_pin = pin - 8;
        regs.PORTB.DDRB.* |= @as(u8, @intFromEnum(dir)) << actual_pin;
    } else if (pin <= 7) {
        regs.PORTD.DDRD.* |= @as(u8, @intFromEnum(dir)) << pin;
    } else {
        @compileError("Invalid pin number. Valid pins are 0-13.");
    }
}

pub fn digitalToggle(comptime pin: u8) void {
    if (pin >= 8 and pin <= 13) {
        const actual_pin = pin - 8;
        var val = regs.PORTB.PORTB.*;
        val ^= 1 << actual_pin;
        regs.PORTB.PORTB.* = val;
    } else if (pin <= 7) {
        var val = regs.PORTD.PORTD.*;
        val ^= 1 << pin;
        regs.PORTD.PORTD.* = val;
    } else {
        @compileError("Invalid pin number. Valid pins are 0-13.");
    }
}

pub fn analogInit(pin: u4) void {
    // ADC 핀 설정 (ADMUX 레지스터 설정)
    regs.ADC.ADMUX.modify(.{
        .MUX = pin, // 핀 번호 선택
        .REFS = 0b01, // AVCC with external capacitor at AREF pin
        .ADLAR = 0, // 결과를 오른쪽 정렬 (10비트 분해능)
    });

    // ADC 활성화 (ADEN 비트 설정)
    regs.ADC.ADCSRA.modify(.{
        .ADEN = 1,
        .ADPS = 0b111, // 128 분주비로 ADC 클럭 설정 (CPU 클럭 16MHz 기준)
    });
}
pub fn read() u16 {
    // 변환 시작 (ADSC 비트 설정)
    regs.ADC.ADCSRA.modify(.{
        .ADSC = 1,
    });

    // 변환 완료 대기 (ADSC 비트가 0이 될 때까지)
    while (regs.ADC.ADCSRA.read().ADSC != 0) {}

    // 10비트 ADC 결과 반환
    return regs.ADC.ADC.*;
}
