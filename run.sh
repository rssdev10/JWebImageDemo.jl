#/bin/bash

terminate_all() {
	kill -9 $PID
	exit 0
}

trap terminate_all SIGHUP SIGINT SIGTERM


julia --project=@. --sysimage=sysimage/image.so ./run.jl &
PID=$!
wait $PID
