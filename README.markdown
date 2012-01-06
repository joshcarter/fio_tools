# FIO Tools

This is a collection of benchmarks and post-analysis tools for use with [fio](http://git.kernel.dk/?p=fio.git).

## Benchmark

`bin/benchmark` is a CLI tool for running benchmarks. Run without parameters for help. Sample use:

    ./bin/benchmark --log=/tmp/benchmark_log profile --device=sdb --runtime=1m

Global options are specified first:

* `--log` : directory to store log files.

Next is the benchmark to run. Options:

* `profile` : overall profile for random read/write at a range of block sizes.

(Note, the master FIO files for all options are in `lib/jobs`.)

Finally are job-specific options. Run `benchmark help [command]` to see options for each command.

## Analysis Tools

Various [R](http://www.r-project.org) scripts for analyzing FIO output are in the `analysis` directory.

TBD: document these.

## Other Stuff

### Bandwidth from clat

`bin/bw_from_clat` is a tool used to generate per-second bandwidth given a FIO completion latency (clat) log.

### FIO Benchmarks

The gaggle of benchmarks under the `benchmarks` directory will eventually migrate into FIO jobs that you can run via `bin/benchmark`.
