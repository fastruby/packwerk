#!/bin/bash
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)"
export CFLAGS="-Wno-error=implicit-function-declaration -Wno-error=deprecated-declarations"
export LDFLAGS="-L$(brew --prefix openssl@3)/lib"
export CPPFLAGS="-I$(brew --prefix openssl@3)/include"
mise install ruby@2.3.8
