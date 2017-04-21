#!/bin/bash

set -e

if [ -z "$@" ]; then
  vagrant up
else
  vagrant "$@"
fi
