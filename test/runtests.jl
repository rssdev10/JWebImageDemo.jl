using JWebImageDemo
using FileIO
using Test
using Dates

function log(str)
    "$(Dates.format(Dates.now(), "dd.mm.yyyy HH:MM:SS")) - $(str)\n"
end

tests = [
    "./image_proccess_test.jl"
    "./service_test.jl"
]

@info log("Running tests....")
for test in tests
    @info log("Test: " * test)
    include(test)
end
@info log("done.")
