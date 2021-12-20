using JWebImageDemo
using Test

import HTTP

const ON_HEROKU = "true"
const PORT = rand(8090:9999)
const HOST = "127.0.0.1"
const VERBOSE = 2

const TEST_IMAGE = joinpath(@__DIR__, "resources", "green_python.jpg")
const NUM = 5

const TEST_REQUESTS = Dict(
    "f_image" => HTTP.Multipart("test.jpg", open(TEST_IMAGE)),
    "num" => HTTP.Multipart(nothing, IOBuffer("5"), "plain/text")
)

@info "Running web service"
service = @async JWebImageDemo.AppServer.start_server(;host = string(HOST), port = PORT)

sleep(10)
@testset "web service" begin
   for i = 1:10
        try
            r = HTTP.get("http://$(HOST):$(PORT)/"; verbose = VERBOSE)
            # dump(r)
            @test r.status == 200
            @test contains(String(r.body), "form")

            r = HTTP.post(
                "http://$(HOST):$(PORT)/api/process_image/",
                HTTP.Form(TEST_REQUESTS);
                verbose = VERBOSE,
            )
            # dump(r)
            @info "Status: $(r.status)"
            @test r.status == 200
            @test any(t -> contains(t.first, "Content-Type") && 
                           contains(t.second, "image/png"),
                      r.headers)
            
           break
        catch
        end
        sleep(30)
   end
end

ex = InterruptException()
@async Base.throwto(service, ex)
sleep(5)
