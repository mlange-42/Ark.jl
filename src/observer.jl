
macro Observer(args...)
    if length(args) < 3
        error("@Observer requires at least a world, an event type and a callback")
    end

    fn_expr = args[1]
    world_expr = args[2]
    event_expr = args[3]

    # Default values
    comps_expr = :(())
    with_expr = :(())
    without_expr = :(())
    exclusive_expr = :false

    # Parse simulated keyword arguments
    for arg in args[4:end]
        if Base.isexpr(arg, :(=), 2)
            name, value = arg.args
            if name == :components
                comps_expr = value
            elseif name == :with
                with_expr = value
            elseif name == :without
                without_expr = value
            elseif name == :exclusive
                exclusive_expr = value
            else
                error(lazy"Unknown keyword argument: $name")
            end
        else
            error(lazy"Unexpected argument format: $arg")
        end
    end

    quote
        Observer(
            $(esc(fn_expr)),
            $(esc(world_expr)),
            $(esc(event_expr));
            components=Val.($(esc(comps_expr))),
            with=Val.($(esc(with_expr))),
            without=Val.($(esc(without_expr))),
            exclusive=Val($(esc(exclusive_expr))),
        )
    end
end

function Observer(
    fn::Function,
    world::World,
    event::EventType;
    components::Tuple=(),
    with::Tuple=(),
    without::Tuple=(),
    exclusive::Val=Val(false),
)
    _Observer_from_types(
        world, event,
        FunctionWrapper{Nothing,Tuple{Entity}}(fn),
        components, with, without, exclusive)
end

@generated function _Observer_from_types(
    world::W,
    event::EventType,
    fn::FunctionWrapper{Nothing,Tuple{Entity}},
    ::CT,
    ::WT,
    ::WO,
    ::EX,
) where {W<:World,CT<:Tuple,WT<:Tuple,WO<:Tuple,EX<:Val}
    comp_types = [x.parameters[1] for x in CT.parameters]
    with_types = [x.parameters[1] for x in WT.parameters]
    without_types = [x.parameters[1] for x in WO.parameters]

    if EX === Val{true} && !isempty(without_types)
        error("cannot use 'exclusive' with 'without'")
    end

    # Component IDs
    id_exprs = Expr[:(_component_id(world, $(QuoteNode(T)))) for T in comp_types]
    with_ids_exprs = Expr[:(_component_id(world, $(QuoteNode(T)))) for T in with_types]
    without_ids_exprs = Expr[:(_component_id(world, $(QuoteNode(T)))) for T in without_types]

    # Mask construction
    mask_expr = :(_Mask($(id_exprs...)))
    with_mask_expr = :(_Mask($(with_ids_exprs...)))

    if EX === Val{true}
        exclude_mask_expr = :(_MaskNot($(with_ids_exprs...)))
    else
        exclude_mask_expr = :(_Mask($(without_ids_exprs...)))
    end

    has_excluded = (length(without_types) > 0) || (EX === Val{true})
    has_excluded_expr = has_excluded ? :(true) : :(false)

    return quote
        obs = Observer(
            _ObserverID(UInt32(0)),
            world,
            event,
            $mask_expr,
            $with_mask_expr,
            $exclude_mask_expr,
            $has_excluded_expr,
            fn,
        )
        register_observer!(world, obs)
        obs
    end
end
