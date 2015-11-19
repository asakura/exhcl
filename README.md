# ExHCL

[![Build Status](https://travis-ci.org/asakura/exhcl.svg?branch=master)](https://travis-ci.org/asakura/exhcl)
[![Inline docs](http://inch-ci.org/github/asakura/exhcl.svg?branch=master&style=flat)](http://inch-ci.org/github/asakura/exhcl)

Configuration language inspired by HCL

```elixir
Erlang/OTP 18 [erts-7.1] [source] [64-bit] [smp:8:8] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Interactive Elixir (1.1.1) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> content = """
...(1)> database pg1 { username = "testuser", password = "password" }
...(1)> """
"database pg1 { username = \"testuser\", password = \"password\" }\n"
iex(2)> Exhcl.Parser.parse(content)
{:ok, %{database: %{pg1: %{password: "password", username: "testuser"}}}}
```

## An example

```hcl
deamon = true

// Store data within Consul. This backend supports HA.
// It is the most recommended backend for Vault and has been shown to
// work at high scale under heavy load.
backend "consul" {
  address = "127.0.0.1:8500"
  path = "vault"
}

/* Configures how Vault is listening for API requests.
 * "tcp" is currently the only option available.
 * A full reference for the inner syntax is below. */
listener "tcp" {
  address = "127.0.0.1:8200"
  tls_disable = 1
}

# Configures the telemetry reporting system (see below).
telemetry {
  statsite_address = "127.0.0.1:8125"
  disable_hostname = true
}
```

It will be converted to follow Elixir representation:

```elixir
%{deamon: true,
  backend: %{"consul" => %{address: "127.0.0.1:8500",
                           path: "vault"}},
  listener: %{"tcp" => %{address: "127.0.0.1:8200",
                         tls_disable: 1}},
  telemetry: %{disable_hostname: true,
               statsite_address: "127.0.0.1:8125"}}
```

## Syntax

* Comments: `//`, `#`, `/* */`
* Bools: `true`, `false`
* Numbers: `1`, `2`, `123`
* Float: `1.01`, `1.02`
* Scientific notation for float numbers: `1.02e+15`, `1.0e-9`
* Strings: `"text"`
* Atoms: `address`, `listener`, and etc
* Arrays: `[1, 1.02, 1.02e+15, "string"]`
* Arrays of arrays: `[[1], [2], [3]]`
* Maps: `telemetry { enable = true }`
