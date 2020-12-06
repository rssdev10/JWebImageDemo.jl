FROM julia:1.5.3

RUN apt-get update
RUN yes | apt-get install bzip2 wget gcc clang

COPY . /opt/webapp

WORKDIR /opt/webapp

RUN julia --project=@. build.jl
RUN julia --project=@. precompile.jl

ENV ON_HEROKU true
ENV PORT 8080

EXPOSE 8080

#CMD ["julia", "--project=@.", "./src/run.jl"]
CMD ["julia", "--threads=auto", "--sysimage=sysimage/image.so", "--project=@.", "./src/server.jl"]
