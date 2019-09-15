#!/usr/bin/env julia --project=@.

using Bukdu # pipeline Conn routes resources get plug Router
using Sockets
using FileIO

using JWebImageDemo

function get_server()
    if haskey(ENV, "ON_HEROKU")
        (port=parse(Int, ENV["PORT"]), host=Sockets.IPAddr(0,0,0,0))
    else
        (port=8080, host=ip"127.0.0.1")
    end
end

server = get_server()

struct WelcomeController <: ApplicationController
    conn::Conn
end

import HTTP, HTTP.Parsers

"""
Workaround while this feature is not implemented in HTTP.jl
https://www.ietf.org/rfc/rfc2616.txt
"""
function parse_multipart(data::Vector{UInt8})
    chunk_end = HTTP.Parsers.find_end_of_chunk_size(data)
    if chunk_end == 0
        return nothing
    end

    boundary = data[1:chunk_end - 2] # without \r\n
    header_end = HTTP.Parsers.find_end_of_header(data)

    data_start = header_end + 1
    data_end = length(data) - chunk_end - 2
    # check that ending is with same boundary + two additional hyphens
    if (data[data_end + 1: end] == [boundary..., 0x2d, 0x2d, 0x0d, 0x0a])
        result = data[data_start : data_end]
        length(result) > 10 && return result # fails on empty new lines
    end
    return nothing
end

"""
Process incomming query with image file
Generate output image in PNG format
"""
function process_image(c::WelcomeController)
    data = parse_multipart(c.conn.request.body)
    # dump(c.conn.request)
    if data != nothing
        buf = IOBuffer(data)
        img = FileIO.load(Stream(format"PNG", buf))
        out_img = JWebImageDemo.permute_image(img) # , 5)
        out_buf = IOBuffer()
        FileIO.save(Stream(format"PNG", out_buf), out_img)
        return Render("image/png", take!(out_buf))
    end
    render(Text, "Please upload some image file")
end

routes() do
    plug(Plug.Static, at="/", from=normpath(@__DIR__, "..", "public"))

    post("/api/process_image", WelcomeController, process_image)
end

Bukdu.start(server.port; host=server.host)

Router.call(get, "/") #
# CLI.routes()

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()
