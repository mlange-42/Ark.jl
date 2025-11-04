
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
        Observer(
            event,
            $mask_expr,
            $with_mask_expr,
            $exclude_mask_expr,
            $has_excluded_expr,
            fn,
        )
    end
end
