using JWebImageDemo
using FileIO
using Test

const TEST_IMAGE = joinpath(@__DIR__, "resources/green_python.jpg")
const NUM = 5

const TMP_PATH = "tmp"
isdir(TMP_PATH) || mkdir(TMP_PATH)

@testset "image permute test" begin
    img = FileIO.load(TEST_IMAGE)
    for i = 2:NUM
        @time img_out = JWebImageDemo.permute_image(img, i)
        # save(Stream{format"PNG"}(io), data...)
        @test size(img) != size(img_out) ||
            any(((i, o),) -> i != o, zip(iterate(img), iterate(img_out)))
        save(joinpath(TMP_PATH, "out_$i.jpg"), img_out)
    end
end
