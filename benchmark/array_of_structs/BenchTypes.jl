
struct Position
    x::Float64
    y::Float64
end

struct Velocity
    dx::Float64
    dy::Float64
end

struct Payload
    x::Float64
    y::Float64
end

mutable struct AosOuter2
    pos::Position
    vel::Velocity
end

function AosOuter2()
    AosOuter2(Position(0, 0), Velocity(1, 1))
end

mutable struct AosOuter4
    pos::Position
    vel::Velocity
    p1::Payload
    p2::Payload
end

function AosOuter4()
    AosOuter4(
        Position(0, 0), Velocity(1, 1),
        Payload(0, 0), Payload(0, 0),
    )
end

mutable struct AosOuter8
    pos::Position
    vel::Velocity
    p1::Payload
    p2::Payload
    p3::Payload
    p4::Payload
    p5::Payload
    p6::Payload
end

function AosOuter8()
    AosOuter8(
        Position(0, 0), Velocity(1, 1),
        Payload(0, 0), Payload(0, 0),
        Payload(0, 0), Payload(0, 0),
        Payload(0, 0), Payload(0, 0),
    )
end

mutable struct AosOuter16
    pos::Position
    vel::Velocity
    p1::Payload
    p2::Payload
    p3::Payload
    p4::Payload
    p5::Payload
    p6::Payload
    p7::Payload
    p8::Payload
    p9::Payload
    p10::Payload
    p11::Payload
    p12::Payload
    p13::Payload
    p14::Payload
end

function AosOuter16()
    AosOuter16(
        Position(0, 0), Velocity(1, 1),
        Payload(0, 0), Payload(0, 0),
        Payload(0, 0), Payload(0, 0),
        Payload(0, 0), Payload(0, 0),
        Payload(0, 0), Payload(0, 0),
        Payload(0, 0), Payload(0, 0),
        Payload(0, 0), Payload(0, 0),
        Payload(0, 0), Payload(0, 0),
    )
end

mutable struct AosFlat2
    x::Float64
    y::Float64
    dx::Float64
    dy::Float64
end

function AosFlat2()
    AosFlat2(0, 0, 1, 1)
end

mutable struct AosFlat4
    x::Float64
    y::Float64
    dx::Float64
    dy::Float64
    p1::Float64
    p2::Float64
    p3::Float64
    p4::Float64
end

function AosFlat4()
    AosFlat4(0, 0, 1, 1, 0, 0, 0, 0)
end

mutable struct AosFlat8
    x::Float64
    y::Float64
    dx::Float64
    dy::Float64
    p1::Float64
    p2::Float64
    p3::Float64
    p4::Float64
    p5::Float64
    p6::Float64
    p7::Float64
    p8::Float64
    p9::Float64
    p10::Float64
    p11::Float64
    p12::Float64
end

function AosFlat8()
    AosFlat8(0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end
