### Patch Selection Enhancement
This fork improves the patching system by enabling **selective application of bug patches**:
- **Setup patches** (in `patches/setup/`) are always applied automatically.
- **Bug patches** (in `patches/bugs/`) can now be selectively applied by setting the `BUGS` environment variable to a space-separated list of patch names **without the `.patch` extension**.

### Why This Enhancement
In the original Magma Benchmark setup, **all bug patches** (e.g., `PNG001.patch`, `PNG002.patch` for libpng) are applied before fuzzing. Each patch inserts a `MAGMA_LOG(...)` statement to mark a target location. [Titan](https://github.com/5hadowblad3/Titan) later relies on these markers to identify vulnerable lines as shown below and conducts consequent static analysis. 

```shell
echo "targets"
grep -nr MAGMA_LOG | cut -f1,2 -d':' | grep -v ".orig:"  | grep -v "Binary file" > $OUT/cstest.txt
cat $OUT/cstest.txt
```
This behavior makes it difficult to **fuzz only a selected subset of bugs** using Magma Benchmark.
For example, one might want to fuzz only specific bugs (like `PNG001`, `PNG004`, and `PNG011`). This enhancement allows users to fuzz specific CVEs (bugs) by supporting both **single-target** and **multi-target** directed fuzzing, making the fuzzing process more targeted and efficient.

### Example Usage
To build with only `PNG001.patch`, run:
```shell
cd tools/captain

# Build the docker image for directed fuzzer and a Magma target (e.g., libpng)
BUGS="PNG001" FUZZER=beacon TARGET=libpng ./build.sh

# To start a single 24-hour fuzzing campaign, use the start.sh script
mkdir -p ./workdir
FUZZER=beacon TARGET=libpng PROGRAM=libpng_read_fuzzer SHARED=./workdir POLL=5 TIMEOUT=24h ./start.sh
```
