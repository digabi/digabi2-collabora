#!/usr/bin/env bash

OLD_VERSION=$(git ls-remote --tags --refs --sort="v:refname" git@github.com:digabi/digabi2-collabora.git | tail -n1 | sed 's/.*\///' 2>/dev/null || echo "v0.0.0")

docker build -t "863419159770.dkr.ecr.eu-north-1.amazonaws.com/collabora:$OLD_VERSION" .