
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
