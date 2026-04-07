# Alignment validation and performance

rammap 0.1.0 vs minimap2 2.30-r1290

# GRCh38 Full-Genome Benchmark (8 Threads)

## System

| | |
|---|---|
| **CPU** | AMD Ryzen 9 7900X 12-Core (24 threads) |
| **RAM** | 128 GB DDR5 |
| **OS** | Ubuntu 22.04, Linux 6.8.0-94-generic |
| **SIMD** | SSE4.1, AVX2, AVX512BW |
| **Rust** | 1.94.0 |
| **Profile** | `opt-level=3`, `lto="fat"`, `codegen-units=1` |

## Test Data

All tests use the full human GRCh38 reference (3.1 GB, 3.09 Gbp). Both tools build
indices from FASTA at runtime (no pre-built `.mmi`). Reads subsampled from full datasets.

| Type | File | Reads |
|------|------|------:|
| ONT (long) | `ont_20000.fq` | 20,000 |
| PacBio HiFi (long) | `hifi_20000.fq` | 20,000 |
| Direct RNA | `rna_5000.fq` | 5,000 |
| Illumina PE | `sr_20000_R{1,2}.fq` | 19,985 pairs |
| ONT overlap | `ava_1000.fq` | 1,000 |
| Assembly contigs | `asm_contigs.fa` | 20 |

---

## Concordance Summary

All core presets produce identical output between rammap and minimap2, with known
exceptions for inversion UB diffs and SAM header differences.

| # | Test | Lines | Result | Notes |
|--:|------|------:|--------|-------|
| 1 | map-ont | 35,083 | **100% concordance** | |
| 2 | map-ont-cigar | 32,732 | **100% concordance** | |
| 3 | map-ont-sam | 33,196 alns | **100% concordance** | 2 SAM @PG header diffs |
| 4 | lr-hq | 31,579 | **100% concordance** | |
| 5 | lr-hqae | 44,954 | **100% concordance** | |
| 6 | map-hifi | 26,006 | **100% concordance** | |
| 7 | map-pb | 26,482/26,483 | **PASS** | 5 diffs: cm:i ±1 + 1 inversion UB |
| 8 | map-iclr | 32,747 | **100% concordance** | |
| 9 | splice | 8,040 | **100% concordance** | |
| 10 | splice-hq | 7,273 | **100% concordance** | |
| 11 | cdna | 8,040 | **100% concordance** | |
| 12 | sr | 39,965 | **100% concordance** | |
| 13 | sr-sam | 40,427 alns | **100% concordance** | 2 SAM @PG header diffs |
| 14 | splice-sr | 39,611 | **100% concordance** | |
| 15 | asm5 | 20 | **100% concordance** | |
| 16 | asm10 | 20 | **100% concordance** | |
| 17 | asm20 | 20 | **100% concordance** | |
| 18 | ava-ont | 209,757 | **100% concordance** | |
| 19 | custom-scoring | 32,286 | **100% concordance** | |
| 20 | secondary-N5 | 32,732 | **100% concordance** | |
| 21 | eqx | 32,732 | **100% concordance** | |
| 22 | custom-kw | 32,327 | **100% concordance** | |

---

## Performance Comparison (8 Threads)

Wall time and peak RSS for rammap (RT) vs minimap2 (MM2). Both tools index from
FASTA at runtime. Wall ratio < 1.0 means rammap is faster.

### Long-Read Presets

| Preset | RT Wall | MM2 Wall | Wall Ratio | RT Mem | MM2 Mem | Mem Ratio |
|--------|--------:|---------:|-----------:|-------:|--------:|----------:|
| map-ont | 145s | 247s | **0.58x** | 10.8 GB | 9.9 GB | 1.09x |
| map-ont-cigar | 162s | 264s | **0.61x** | 10.8 GB | 13.8 GB | **0.78x** |
| map-ont-sam | 163s | 262s | **0.62x** | 10.8 GB | 14.1 GB | **0.77x** |
| lr-hq | 70s | 68s | 1.02x | 13.8 GB | 18.0 GB | **0.77x** |
| lr-hqae | 62s | 56s | 1.09x | 6.0 GB | 9.1 GB | **0.66x** |
| map-hifi | 56s | 47s | 1.19x | 13.6 GB | 17.2 GB | **0.79x** |
| map-pb | 64s | 55s | 1.15x | 8.4 GB | 12.9 GB | **0.65x** |
| map-iclr | 103s | 93s | 1.10x | 15.8 GB | 16.4 GB | **0.96x** |

### Splice / RNA Presets

| Preset | RT Wall | MM2 Wall | Wall Ratio | RT Mem | MM2 Mem | Mem Ratio |
|--------|--------:|---------:|-----------:|-------:|--------:|----------:|
| splice | 57s | 40s | 1.42x | 18.3 GB | 19.1 GB | **0.96x** |
| splice-hq | 58s | 41s | 1.42x | 18.3 GB | 19.1 GB | **0.96x** |
| cdna | 59s | 41s | 1.45x | 18.3 GB | 19.1 GB | **0.96x** |
| splice-sr | 56s | 39s | 1.43x | 18.3 GB | 19.1 GB | **0.96x** |

### Short-Read Presets

| Preset | RT Wall | MM2 Wall | Wall Ratio | RT Mem | MM2 Mem | Mem Ratio |
|--------|--------:|---------:|-----------:|-------:|--------:|----------:|
| sr | 45s | 30s | 1.52x | 13.9 GB | 13.5 GB | 1.03x |
| sr-sam | 45s | 30s | 1.52x | 13.9 GB | 13.6 GB | 1.02x |

### Assembly Presets

| Preset | RT Wall | MM2 Wall | Wall Ratio | RT Mem | MM2 Mem | Mem Ratio |
|--------|--------:|---------:|-----------:|-------:|--------:|----------:|
| asm5 | 40s | 29s | 1.37x | 12.6 GB | 14.8 GB | **0.85x** |
| asm10 | 40s | 29s | 1.38x | 12.6 GB | 14.8 GB | **0.85x** |
| asm20 | 50s | 33s | 1.51x | 15.1 GB | 14.3 GB | 1.06x |

### Overlap / Parameter Variations

| Preset | RT Wall | MM2 Wall | Wall Ratio | RT Mem | MM2 Mem | Mem Ratio |
|--------|--------:|---------:|-----------:|-------:|--------:|----------:|
| ava-ont | 9s | 11s | **0.81x** | 1.3 GB | 1.4 GB | **0.93x** |
| custom-scoring | 157s | 256s | **0.61x** | 10.8 GB | 13.6 GB | **0.79x** |
| secondary-N5 | 157s | 256s | **0.61x** | 10.8 GB | 13.7 GB | **0.79x** |
| eqx | 155s | 257s | **0.60x** | 10.8 GB | 13.7 GB | **0.79x** |
| custom-kw | 84s | 89s | **0.94x** | 15.4 GB | 18.2 GB | **0.85x** |

---

## GRCh38 Performance Summary

**Wall time ratio** (rammap / minimap2; lower is better):

```
Faster  ============================|============================  Slower
                                    |
        map-ont      0.58x  ████████|
        eqx          0.60x  ████████|
        map-ont-cig  0.61x  ████████|
        custom-scor  0.61x  ████████|
        secondary-N5 0.61x  ████████|
        map-ont-sam  0.62x  ████████|
        ava-ont      0.81x      ████|
        custom-kw    0.94x         █|
        lr-hq        1.02x          |
        lr-hqae      1.09x          |██
        map-iclr     1.10x          |███
        map-pb       1.15x          |████
        map-hifi     1.19x          |█████
        asm5         1.37x          |█████████
        asm10        1.38x          |█████████
        splice       1.42x          |██████████
        splice-hq    1.42x          |██████████
        splice-sr    1.43x          |███████████
        cdna         1.45x          |███████████
        asm20        1.51x          |█████████████
        sr           1.52x          |█████████████
        sr-sam       1.52x          |█████████████
```

### Key Observations (GRCh38, 8 threads)

**Faster than minimap2**:
- map-ont/map-ont-cigar/map-ont-sam: **38-42% faster** — primary ONT use case
- custom-scoring/secondary-N5/eqx: **39-40% faster** (same ONT pipeline with extra output)
- ava-ont: **19% faster** — overlap mode
- custom-kw: **6% faster**

**On par with minimap2**:
- lr-hq: parity (1.02x)
- lr-hqae/map-iclr: **9-10% slower**
- map-pb/map-hifi: **15-19% slower** — HPC index overhead

**Slower than minimap2** (index-build-dominated tests with few reads):
- splice/cdna/splice-hq: **1.42-1.45x slower** — sequential sketch dominates with few reads
- sr: **1.52x slower** — sequential sketch + small read count
- asm: **1.37-1.51x slower** — index build overhead, only 20 contigs aligned

### Memory

rammap consistently uses **less memory** than minimap2 across almost all presets,
with significant savings on long-read alignment modes:

- **34-35% less memory**: lr-hqae (0.66x), map-pb (0.65x)
- **21-23% less memory**: map-ont-cigar (0.78x), map-hifi (0.79x), lr-hq/custom-scoring (0.77-0.79x)
- **4-15% less memory**: custom-kw (0.85x), asm5/10 (0.85x), splice (0.96x)
- **~parity or slightly more**: map-ont mapping-only (1.09x), sr (1.03x), asm20 (1.06x)

---

## Known Differences

### GRCh38 Tests

| Test | Diffs | Explanation |
|------|------:|-------------|
| map-pb | 5 | 4x `cm:i:` ±1 (chain minimizer count) + 1 known `ksw_ll_i16` UB inversion (`cm:i:0, s1:i:0`). |
| map-ont-sam / sr-sam | 2 | SAM `@PG` header line differences (program name/version). Not alignment diffs. |

### SIMD Tie-Breaking

Different SIMD widths (SSE=16 lanes, AVX2=32, AVX512=64) can produce
different CIGAR strings for the same input when multiple cells in the DP
matrix have equal scores. The traceback direction bits depend on the order
cells are processed within a SIMD register, and wider registers process
more cells per iteration, changing which tied cell "wins."

This is inherent to all banded SIMD DP implementations, including
minimap2's C ksw2. It does not affect scores, alignment boundaries, or
consumed lengths — only the placement of gaps within equally-scored
regions. The mapper's integration tests confirm all SIMD variants
produce byte-identical output because the chaining/filtering pipeline
eliminates borderline alignments before output.

### minimap2 UB

For details on the `ksw_ll_i16` undefined behavior that causes the
inversion diffs, see [`docs/minimap2-ksw-ll-ub.md`](minimap2-ksw-ll-ub.md).

---

## Threading Model

### rammap

| Component | Threading | Notes |
|-----------|-----------|-------|
| FASTA reading | Single | Sequential I/O |
| Index sketching | Sequential | One sequence at a time (minimizes peak memory) |
| Index 4-bit packing | Sequential | Fused with sketching in single pass |
| Index bucket sort | Parallel | rayon `par_iter_mut` over 1024 buckets |
| Per-bucket hash table | Sequential | Process and free one bucket at a time |
| Query I/O | Dedicated read-ahead thread | `sync_channel(1)` overlapped I/O |
| Mapping (seed/chain/align) | `-t N` worker threads | Crossbeam scoped threads |
| Output formatting | Per-thread, flushed in order | Buffered writes |

### minimap2

| Component | Threading | Notes |
|-----------|-----------|-------|
| FASTA reading | Single | mmap for .mmi index |
| Index sketching | Thread pool | `kt_for` over sequences |
| Index sort/hash | Thread pool | `kt_for` over buckets (16K independent) |
| Query I/O | Pipeline step 0 | 3-stage pipeline: read → map → output |
| Mapping (seed/chain/align) | `-t N` worker threads | `kt_pipeline` step 1 |
| Output formatting | Pipeline step 2 | Sequential output step |

### Key Differences

- **Index build**: rammap sketches sequentially (one sequence at a time, dropping ASCII
  immediately to minimize peak memory), then sorts buckets in parallel via rayon.
  Per-bucket hash table construction is sequential to avoid holding all results
  simultaneously. minimap2 parallelizes both sketching (across sequences) and bucket
  post-processing (across 16K buckets) via `kt_for`.
- **Index structure**: rammap uses per-bucket open-addressing hash tables (minimap2-style)
  with a shared flat positions array. Singletons and multi-occurrence hashes are both
  stored in the positions array for uniform `get_range`/`get_by_range` API.
- **I/O pipeline**: minimap2 uses a 3-stage pipeline (`kt_pipeline`) that overlaps
  reading, mapping, and output. rammap uses a dedicated read-ahead thread with a
  synchronous channel, achieving similar overlap.
- **DP kernels**: minimap2 dispatches to SSE4.1 or SSE2 only (NEON via sse2neon on
  aarch64). rammap has native NEON, AVX2, and AVX512BW DP kernels in addition to
  SSE, providing wider SIMD on all platforms.

---

## aarch64 (Apple Silicon) Benchmark — ONT 1M Reads

### System

| | |
|---|---|
| **CPU** | Apple M-series (aarch64) |
| **SIMD** | NEON (128-bit, 16 lanes) |
| **Rust** | stable, `opt-level=3`, `lto="fat"`, `codegen-units=1` |

### Test Data

| File | Size | Reads |
|------|------|------:|
| T2T\_chrXPAR\_masked.fa | 2.9 GB | 25 target sequences |
| 1m.fastq | 1.5 GB | 1,000,000 ONT reads |

Preset: `map-ont` with CIGAR (`-cx map-ont`), 4 threads.

### Overall Performance

| Metric | minimap2 | rammap | Ratio |
|--------|----------|--------|-------|
| **Wall time** | 174s | 204s | 1.18x |
| **CPU time** | 605s | 634s | 1.05x |
| **Peak RSS** | 19.0 GB | 14.7 GB | **0.77x** |
| Index build | 37s | 43s | 1.16x |
| Mapping | 135s | 204s | — |
| Output | identical | identical | — |

### Stage-Level CPU Breakdown (4 threads, summed)

| Stage | minimap2 | rammap | Ratio | Notes |
|-------|----------|--------|-------|-------|
| Sketching | 9.1s | 8.2s | 0.91x | |
| Seeding | 234.5s | 208.1s | **0.89x** | FxHashMap lookup faster than khash |
| Initial DP chain | 96.3s | 129.5s | 1.34x | |
| RMQ rescue chain | 87.0s | 117.1s | 1.35x | Arena AVL vs intrusive AVL (krmq) |
| Post-chain | 4.1s | 6.1s | 1.49x | |
| Alignment (DP ext) | 102.0s | 116.0s | 1.14x | NEON SIMD scoring |
| **Total measured** | **533s** | **585s** | **1.10x** | |

### aarch64 Notes

**Faster than minimap2:**
- **Seeding 11% faster**: Per-bucket open-addressing hash tables (u32 keys, linear
  probing) with O(1) lookup. Cached `get_range`/`get_by_range` avoids double lookup
  in the seed collection hot path.
- **23% less peak memory**: Sequential sketch-and-distribute pipeline processes one
  chromosome at a time (sketch, pack 4-bit, distribute to buckets, free ASCII), so
  peak memory is just the growing buckets + packed sequences. Parallel bucket sort via
  rayon, then sequential per-bucket hash table build (each bucket processed and freed
  independently, matching minimap2's `worker_post`). Shared flat `Vec<u64>` positions
  array for all hashes (including singletons).

**Slower than minimap2:**
- **Alignment 1.14x slower**: NEON DP kernels use native intrinsics; minimap2 uses
  SSE2 intrinsics auto-translated to NEON via sse2neon. Remaining gap is likely
  register allocation and bounds-check overhead in Rust.
- **Index build 1.16x slower**: Sequential sketching (one chromosome at a time for
  lower peak memory) vs minimap2's parallel `kt_for` over sequences. Parallelism
  recovered in the bucket sort phase (rayon `par_iter_mut` over 1024 buckets).
