#!/usr/bin/env julia --project=@.

using Bukdu # pipeline Conn routes resources get plug Router
using Sockets
using FileIO

using JWebImageDemo

function get_server()
    if haskey(ENV, "ON_HEROKU")
        (port = parse(Int, ENV["PORT"]), host = ip"0.0.0.0")
    else
        (port = 8080, host = ip"127.0.0.1")
    end
end

server = get_server()

struct WelcomeController <: ApplicationController
    conn::Conn
end

import HTTP, HTTP.Parsers

get(multipart::Vector{HTTP.Multipart}, name::String) =
    findfirst(part -> part.name == name, multipart) |>
    idx -> isnothing(idx) ? nothing : multipart[idx]

# function get(multipart::Vector{HTTP.Multipart}, name::String)::Union{HTTP.Multipart, Nothing}
#     for part in multipart
#         if part.name == name
#             return part
#         end
#     end
#     return nothing
# end

"""
Process incomming query with image file
Generate output image in PNG format
"""
function process_image(c::WelcomeController)
    local multiparts = HTTP.parse_multipart_form(c.conn.request)

    # dump(multiparts)
    local mp_file = get(multiparts, "f_image")
    local mp_num = get(multiparts, "num")

    isnothing(mp_file) &&
        return render(Text, "Please upload some image file in f_image field")
    isnothing(mp_num) &&
        return render(Text, "Please specify number of sections in num field")

    local img = FileIO.load(Stream(format"PNG", mp_file.data))
    local out_img = JWebImageDemo.permute_image(
        img,
        tryparse(Int, String(take!(mp_num.data))) |> x -> something(x, 5),
    )
    local out_buf = IOBuffer()
    FileIO.save(Stream(format"PNG", out_buf), out_img)
    return Render(mp_file.contenttype, identity, take!(out_buf))
end

routes() do
    plug(Plug.Static, at = "/", from = normpath(@__DIR__, "..", "public"))

    post("/api/process_image", WelcomeController, process_image)
end

function start_server()
    Bukdu.start(server.port; host = server.host)

    # Router.call(get, "/") #
    # CLI.routes()

    Base.JLOptions().isinteractive == 0 && wait()
    #Bukdu.stop()
end

endswith(PROGRAM_FILE, basename(@__FILE__)) && start_server()
