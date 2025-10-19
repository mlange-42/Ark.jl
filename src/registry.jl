
struct ComponentRegistry
    components::Dict{DataType, UInt8}
end

function ComponentRegistry()
    ComponentRegistry(Dict{DataType, UInt8}())
end
