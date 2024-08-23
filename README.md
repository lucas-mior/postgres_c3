# postgres_c3
This is an attempt at providing C3 bindings for the pq library, used by postgres
clients, for experimental purposes.

## Files
- `main.c3` contains a simple test program that connects to a database on
  localhost.
- `libpq.c3` is a hand made translation of the libpq headers from my linux
  system.

## How to test it
```
c3c compile-run -l /usr/lib/libpq.so main.c3 postgres.c3
```
