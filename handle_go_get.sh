#! /bin/bash

### Parameters
# 1 - repository to build (URL/path in go get style, where the web https://github.com/<username>/<repo_name>.git has to be written github.com/<username>/<repo_name>
 
### Preparation
script_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

# Breaks with go.mod
unset GOPATH

### Process
go_version=$(go version)
echo "[Compilation container] Info: $go_version"
echo "[Compilation container] Executing go get $1";


curl -L "https://$1/archive/master.tar.gz" \
    | tar -x -z -v -p --strip-components=1
CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static" -s -w' -o systemd-docker .

if [ $? -eq 0 ]; then
	echo "[Compilation container] Success"
	# Overwrite check
	if [ -f "$script_folder/systemd-docker" ]; then
		echo "[Compilation container] Overwriting old systemd-docker"
	fi
	cp systemd-docker "$script_folder/systemd-docker"
else
	error_code_return=$?
	echo "[Compilation container] Error, go get failed with error code $error_code_return"
	exit $error_code_return
fi
