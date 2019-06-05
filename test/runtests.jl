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
