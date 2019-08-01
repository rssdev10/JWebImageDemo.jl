#!/usr/bin/env julia --project=@.

using Bukdu # pipeline Conn routes resources get plug Router
using HTTP: Multipart
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

function process_image(c::WelcomeController)
    image = c.params.image
    dump(image)
    if image isa Multipart && !eof(image)
        buf = image.data
        img = FileIO.load(Stream(format"PNG", buf))
        out_img = JWebImageDemo.permute_image(img, 5)
        out_buf = IOBuffer()
        FileIO.save(Stream(format"PNG", out_buf), out_img)
        return Render("image/png", take!(out_buf))
    end
    render(Text, "Please upload some image file")
end

routes() do
    plug(Plug.Static, at="/", from=normpath(@__DIR__, "../public"))

    post("/api/process_image", WelcomeController, process_image)
end

Bukdu.start(server.port; host=server.host)

Router.call(get, "/") #
# CLI.routes()

Base.JLOptions().isinteractive==0 && wait()

# Bukdu.stop()
