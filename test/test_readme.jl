
@testset "README example" begin
    """Position component"""
    struct Position
        x::Float64
        y::Float64
    end

    """Velocity component"""
    struct Velocity
        dx::Float64
        dy::Float64
    end

    # Create a world with the required components
    world = World(Position, Velocity)

    for i in 1:1000
        # Create an entity with components
        entity = new_entity!(world, (Position(i, i * 2), Velocity(1, 1)))
    end

    # Time loop
    for i in 1:10
        # Iterate a query (archetypes)
        query = @Query(world, (Position, Velocity))
        for _ in query
            # Get entities and component columns of the current archetype
            entities, pos_column, vel_column = query[]
            # Iterate entities in the current archetype
            for i in eachindex(pos_column)
                # Get components of the current entity
                pos = pos_column[i]
                vel = vel_column[i]
                # Update an (immutable) component
                pos_column[i] = Position(pos.x + vel.dx, pos.y + vel.dy)
            end
        end
    end
end
