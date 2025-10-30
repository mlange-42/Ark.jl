
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

mutable struct AosOuter_32B
    pos::Position
    vel::Velocity
end

function AosOuter_32B()
    AosOuter_32B(Position(0, 0), Velocity(1, 1))
end

mutable struct AosOuter_64B
    pos::Position
    vel::Velocity
    p1::Payload
    p2::Payload
end

function AosOuter_64B()
    AosOuter_64B(
        Position(0, 0), Velocity(1, 1),
        Payload(0, 0), Payload(0, 0),
    )
end

mutable struct AosOuter_128B
    pos::Position
    vel::Velocity
    p1::Payload
    p2::Payload
    p3::Payload
    p4::Payload
    p5::Payload
    p6::Payload
end

function AosOuter_128B()
    AosOuter_128B(
        Position(0, 0), Velocity(1, 1),
        Payload(0, 0), Payload(0, 0),
        Payload(0, 0), Payload(0, 0),
        Payload(0, 0), Payload(0, 0),
    )
end

mutable struct AosFlat_32B
    x::Float64
    y::Float64
    dx::Float64
    dy::Float64
end

function AosFlat_32B()
    AosFlat_32B(0, 0, 1, 1)
end

mutable struct AosFlat_64B
    x::Float64
    y::Float64
    dx::Float64
    dy::Float64
    p1::Float64
    p2::Float64
    p3::Float64
    p4::Float64
end

function AosFlat_64B()
    AosFlat_64B(0, 0, 1, 1, 0, 0, 0, 0)
end

mutable struct AosFlat_128B
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

function AosFlat_128B()
    AosFlat_128B(0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

struct AosImmutable_32B
    x::Float64
    y::Float64
    dx::Float64
    dy::Float64
end

function AosImmutable_32B()
    AosImmutable_32B(0, 0, 1, 1)
end

function AosImmutable_32B(x::Float64, y::Float64)
    AosImmutable_32B(x, y, 1, 1)
end

struct AosImmutable_64B
    x::Float64
    y::Float64
    dx::Float64
    dy::Float64
    p1::Float64
    p2::Float64
    p3::Float64
    p4::Float64
end

function AosImmutable_64B()
    AosImmutable_64B(0, 0, 1, 1, 0, 0, 0, 0)
end

function AosImmutable_64B(x::Float64, y::Float64)
    AosImmutable_64B(x, y, 1, 1, 0, 0, 0, 0)
end

struct AosImmutable_128B
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

function AosImmutable_128B()
    AosImmutable_128B(0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

function AosImmutable_128B(x::Float64, y::Float64)
    AosImmutable_128B(x, y, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end
