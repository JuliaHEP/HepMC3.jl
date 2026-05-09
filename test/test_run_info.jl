@testset "Run Information" begin
    @testset "Weight Names and Tools" begin
        event = create_event(314)
        run_info = create_run_info()

        set_weight_names!(run_info, ["nominal", "scale_up", "scale_down"])
        add_tool_info!(run_info, "Pythia8", "8.306", "hard process generator")
        set_run_info!(event, run_info)

        @test get_weight_names(event) == ["nominal", "scale_up", "scale_down"]
        @test has_weight(event, "scale_up")
        @test !has_weight(event, "missing")
        @test weight_index(event, "nominal") == 0
        @test weight_index(event, "scale_down") == 2
        @test weight_index(event, "missing") == -1

        tools = get_tool_infos(event)
        @test length(tools) == 1
        @test tools[1] == (
            name = "Pythia8",
            version = "8.306",
            description = "hard process generator",
        )
    end
end
