
"""
    @observe!(
        fn::Function,
        world::World,
        event::EventType,
        components::Tuple=(),
        with::Tuple=(),
        without::Tuple=(),
        exclusive::Val=Val(false),
        register::Bool=true,
    )

Creates an [Observer](@ref) and (optionally, default) registers it.

Macro version of [`observe!`](@ref) that allows ergonomic construction of observers using simulated keyword arguments.

See [EventType](@ref) for built-in, and [EventRegistry](@ref) for custom event types.

# Arguments

  - `fn::Function`: A callback function to execute when a matching event is received. Can be used via a `do` block.
  - `world::World`: The [World](@ref) to observe.
  - `event::EventType`: The [EventType](@ref) to observe.
  - `components::Tuple=()`: The component types to observe. Must be empty for `OnCreateEntity` and `OnRemoveEntity`.
  - `with::Tuple=()`: Components the entity must have.
  - `without::Tuple=()`: Components the entity must not have.
  - `exclusive::Bool=false`: Makes the observer exclusive for entities that have exactly the components given be `with`.
  - `register::Bool=true`: Whether the observer is registered immediately. Alternatively, register later with [observe!](@ref observe!(::World, ::Observer; ::Bool))

# Example

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
@observe!(world, OnAddComponents, (Position, Velocity), with = (Altitude,)) do entity
    println(entity)
end
; # suppress print output

# output

```
"""
macro observe!(args...)
    if length(args) < 3
        error("observe! requires at least a callback, world, and event type")
    end

    fn_expr    = args[1]
    world_expr = args[2]
    event_expr = args[3]

    # Determine if components were provided
    if length(args) > 3 && !(Base.isexpr(args[4], :(=), 2))
        comps_expr = args[4]
        kw_args = args[5:end]
    else
        comps_expr = :(())
        kw_args = args[4:end]
    end

    # Default keyword values
    with_expr      = :(())
    without_expr   = :(())
    exclusive_expr = :false
    register_expr  = :true

    # Parse simulated keyword arguments
    for arg in kw_args
        if Base.isexpr(arg, :(=), 2)
            name, value = arg.args
            if name == :with
                with_expr = value
            elseif name == :without
                without_expr = value
            elseif name == :exclusive
                exclusive_expr = value
            elseif name == :register
                register_expr = value
            else
                error("Unknown keyword argument: $name")
            end
        else
            error("Unexpected argument format: $arg")
        end
    end

    quote
        observe!(
            $(esc(fn_expr)),
            $(esc(world_expr)),
            $(esc(event_expr)),
            Val.($(esc(comps_expr)));
            with=Val.($(esc(with_expr))),
            without=Val.($(esc(without_expr))),
            exclusive=Val($(esc(exclusive_expr))),
            register=$(esc(register_expr)),
        )
    end
end

"""
    observe!(
        fn::Function,
        world::World,
        event::EventType,
        components::Tuple=();
        with::Tuple=(),
        without::Tuple=(),
        exclusive::Bool=false,
        register::Bool=true,
    )

Creates an [Observer](@ref) and (optionally, default) registers it.

For a more convenient tuple syntax, the macro [`@observe!`](@ref) is provided.

See [EventType](@ref) for built-in, and [EventRegistry](@ref) for custom event types.

# Arguments

  - `fn::Function`: A callback function to execute when a matching event is received. Can be used via a `do` block.
  - `world::World`: The [World](@ref) to observe.
  - `event::EventType`: The [EventType](@ref) to observe.
  - `components::Tuple`: The component types to observe. Must be empty for `OnCreateEntity` and `OnRemoveEntity`.
  - `with::Tuple=()`: Components the entity must have.
  - `without::Tuple=()`: Components the entity must not have.
  - `exclusive::Bool=false`: Makes the observer exclusive for entities that have exactly the components given be `with`.
  - `register::Bool=true`: Whether the observer is registered immediately. Alternatively, register later with [observe!](@ref observe!(::World, ::Observer; ::Bool))

# Example

```jldoctest; setup = :(using Ark; include(string(dirname(pathof(Ark)), "/docs.jl"))), output = false
observe!(world, OnAddComponents, Val.((Position, Velocity)); with=Val.((Altitude,))) do entity
    println(entity)
end
; # suppress print output

# output

```
"""
function observe!(
    fn::Function,
    world::W,
    event::EventType,
    components::Tuple=();
    with::Tuple=(),
    without::Tuple=(),
    exclusive::Val=Val(false),
    register::Bool=true,
) where {W<:World}
    _Observer_from_types(
        world, event,
        FunctionWrapper{Nothing,Tuple{Entity}}(fn),
        components, with, without, exclusive, register)
end

@generated function _Observer_from_types(
    world::W,
    event::EventType,
    fn::FunctionWrapper{Nothing,Tuple{Entity}},
    ::CT,
    ::WT,
    ::WO,
    ::EX,
    register::Bool,
) where {W<:World,CT<:Tuple,WT<:Tuple,WO<:Tuple,EX<:Val}
    comp_types = [x.parameters[1] for x in CT.parameters]
    with_types = [x.parameters[1] for x in WT.parameters]
    without_types = [x.parameters[1] for x in WO.parameters]

    if EX === Val{true} && !isempty(without_types)
        error("cannot use 'exclusive' together with 'without'")
    end

    function get_id(C)
        _component_id(W.parameters[1], C)
    end

    ids = map(get_id, comp_types)
    with_ids = map(get_id, with_types)
    without_ids = map(get_id, without_types)

    mask = _Mask(ids...)
    with_mask = _Mask(with_ids...)
    exclude_mask = EX === Val{true} ? _MaskNot(with_ids...) : _Mask(without_ids...)

    has_comps_expr = (length(comp_types) > 0) ? :(true) : :(false)
    has_with_expr = (length(with_types) > 0) ? :(true) : :(false)
    has_without = (length(without_types) > 0) || (EX === Val{true})
    has_without_expr = has_without ? :(true) : :(false)

    return quote
        if (event == OnCreateEntity || event == OnRemoveEntity) && _is_not_zero($mask)
            error("components tuple must be empty for event types OnCreateEntity and OnRemoveEntity")
        end
        obs = Observer(
            _ObserverID(UInt32(0)),
            event,
            $mask,
            $with_mask,
            $exclude_mask,
            $has_comps_expr,
            $has_with_expr,
            $has_without_expr,
            fn,
        )
        if register
            observe!(world, obs)
        end
        obs
    end
end

"""
    observe!(world::World, observer::Observer; unregister::Bool=false)

Registers or un-registers the given [Observer](@ref).
Note that observers created with [@observe!](@ref) are automatically registered by default.
"""
function observe!(world::World, observer::Observer; unregister::Bool=false)
    if unregister
        _remove_observer!(world._event_manager, observer)
    else
        _add_observer!(world._event_manager, observer)
    end
end
