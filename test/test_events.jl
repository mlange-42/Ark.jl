
@testset "Event type registration" begin
    m = _EventManager()

    @test _event_index(m, Val{:OnCreateEntity}()) == 1
    @test _event_index(m, Val{:OnRemoveEntity}()) == 2

    @test _register_event!(m, :OnCustomEvent) == 3
    @test _event_index(m, Val{:OnCustomEvent}()) == 3
end
