@testset "Round Trip Metadata and I/O State" begin
    function build_metadata_event(event_number_value::Int; run_info = nothing)
        event = create_event(event_number_value)
        set_units!(event, :GeV, :mm)
        set_event_weights!(event, [1.0, 0.5, 2.0])

        if run_info === nothing
            run_info = create_run_info()
            set_weight_names!(run_info, ["nominal", "down", "up"])
            add_tool_info!(run_info, "UnitTestGenerator", "1.0", "round-trip test")
        end
        set_run_info!(event, run_info)

        incoming = make_shared_particle(0.0, 0.0, 100.0, 100.0, 22, 2)
        electron = make_shared_particle(10.0, 0.0, 20.0, 25.0, 11, 1)
        positron = make_shared_particle(-10.0, 0.0, -20.0, 25.0, -11, 1)
        vertex = make_shared_vertex()
        connect_particle_in(vertex, incoming)
        connect_particle_out(vertex, electron)
        connect_particle_out(vertex, positron)
        attach_vertex_to_event(event, vertex)

        return event
    end

    @testset "Run Info and Weights Survive ASCII Round Trip" begin
        event = build_metadata_event(2718)
        filename = tempname() * ".hepmc3"

        writer = HepMC3.create_writer_ascii(filename)
        @test !HepMC3.writer_failed(writer)
        @test HepMC3.writer_write_event(writer, event.cpp_object)
        HepMC3.writer_close(writer)
        HepMC3.delete_writer_ascii(writer)

        reader = HepMC3.create_reader_ascii(filename)
        @test !HepMC3.reader_failed(reader)
        read_event = GenEvent()
        @test HepMC3.reader_read_event(reader, read_event.cpp_object)
        HepMC3.reader_close(reader)
        HepMC3.delete_reader_ascii(reader)

        @test event_number(read_event) == 2718
        @test particles_size(read_event) == 3
        @test vertices_size(read_event) == 1
        @test get_event_weights(read_event) == [1.0, 0.5, 2.0]
        @test get_weight_names(read_event) == ["nominal", "down", "up"]
        @test weight_index(read_event, "up") == 2

        rm(filename)
    end

    @testset "Batch Reader Preserves Event Access" begin
        run_info = create_run_info()
        set_weight_names!(run_info, ["nominal", "down", "up"])
        add_tool_info!(run_info, "UnitTestGenerator", "1.0", "round-trip test")
        event1 = build_metadata_event(1; run_info)
        event2 = build_metadata_event(2; run_info)
        filename = tempname() * ".hepmc3"

        writer = HepMC3.create_writer_ascii(filename)
        @test HepMC3.writer_write_event(writer, event1.cpp_object)
        @test HepMC3.writer_write_event(writer, event2.cpp_object)
        HepMC3.writer_close(writer)
        HepMC3.delete_writer_ascii(writer)

        events = read_hepmc_file(filename)
        @test length(events) == 2
        @test event_number(events[1]) == 1
        @test event_number(events[2]) == 2
        @test get_event_weight_names(events[1]) == ["nominal", "down", "up"]
        @test get_event_weights(events[2]) == [1.0, 0.5, 2.0]
        @test event_weight_index(events[1], "down") == 1

        rm(filename)
    end

    @testset "Reader and Writer Failure State" begin
        reader = HepMC3.create_reader_ascii("definitely_missing_file.hepmc3")
        @test HepMC3.reader_failed(reader)
        HepMC3.delete_reader_ascii(reader)

        invalid_filename = joinpath(tempname(), "missing", "event.hepmc3")
        writer = HepMC3.create_writer_ascii(invalid_filename)
        @test HepMC3.writer_failed(writer)
        @test !HepMC3.writer_write_event(writer, create_event(1).cpp_object)
        HepMC3.delete_writer_ascii(writer)
    end
end
