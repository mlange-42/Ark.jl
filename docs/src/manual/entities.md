# Entities

[Entities](@ref entities-api) are the "game objects" or "model entities" in applications that use Ark.
In effect, an entity is just an ID that can be associated with [Components](@ref),
which contain the entity's properties or state variables.

## Entity creation

An entity can only exist in a [World](@ref), and thus can only be created through a World.
