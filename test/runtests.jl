using JWebImageDemo
using FileIO
using Test

const TEST_IMAGE = joinpath(@__DIR__, "resources/green_python.jpg")
NUM = 5

@testset "JWebImageDemo.jl" begin
    img = FileIO.load(TEST_IMAGE)
    @time img_out = JWebImageDemo.permute_image(img, NUM)
    #save(Stream(format"PNG",io), data...)
    @test size(img) != size(img_out) ||
          any(((i, o),) -> i != o, zip(iterate(img), iterate(img_out)))
    save("out.jpg", img_out)
end

@testset "post process_image" begin
    using Bukdu
    using HTTP: HTTP, Form, Multipart
    using Random

    struct WelcomeController <: ApplicationController
        conn::Conn
    end

    function process_image(c::WelcomeController)
        image = c.params.image
        if image isa Multipart && !eof(image)
            buf = image.data
            img = FileIO.load(Stream(format"PNG", buf))
            Random.seed!(0)
            out_img = JWebImageDemo.permute_image(img, NUM)
            out_buf = IOBuffer()
            FileIO.save(Stream(format"PNG", out_buf), out_img)
            return Render("image/png", take!(out_buf))
        end
        render(Text, "Please upload some image file")
    end

    routes() do
        post("/api/process_image", WelcomeController, process_image)
    end
    Bukdu.start(8191, host="127.0.0.1")

    f = open(TEST_IMAGE)
    part1 = Multipart(basename(TEST_IMAGE), f)
    r = HTTP.post("http://127.0.0.1:8191/api/process_image", Form(["image" => part1]))
    close(f)

    img = FileIO.load(TEST_IMAGE)
    Random.seed!(0)
    out_img = JWebImageDemo.permute_image(img, NUM)
    out_buf = IOBuffer()
    FileIO.save(Stream(format"PNG", out_buf), out_img)
    seekstart(out_buf)
    @test r.body == read(out_buf)

    r = HTTP.post("http://127.0.0.1:8191/api/process_image", Form(["image" => ""]))
    @test r.body == Vector{UInt8}("Please upload some image file")

    Bukdu.stop()
end
