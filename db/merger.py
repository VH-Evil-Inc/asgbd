import re
from collections import defaultdict

# Regular expressions for parsing
proc_header_re = re.compile(r'>>>>> PROC: (\w+)')
metrics_re = re.compile(
    r'CALLS: (\d+)\s+MIN: ([\d.]+)ms\s+AVG: ([\d.]+)ms\s+MAX: ([\d.]+)ms\s+TOTAL: ([\d.]+)ms'
)
extras_re = re.compile(
    r'P99: ([\d.]+)ms\s+P95: ([\d.]+)ms\s+P50: ([\d.]+)ms\s+SD: ([\d.]+)\s+RATIO: ([\d.]+)%'
)

# Data structure for holding aggregated metrics
aggregated = defaultdict(lambda: {
    "calls": 0,
    "total_time": 0.0,
    "min": float("inf"),
    "max": 0.0,
    "weighted_avg_sum": 0.0,
    "weighted_p99_sum": 0.0,
    "weighted_p95_sum": 0.0,
    "weighted_p50_sum": 0.0,
    "weighted_sd_sum": 0.0,
    "weighted_ratio_sum": 0.0
})

def parse_and_aggregate(text):
    lines = text.splitlines()
    current_proc = None
    current_block_calls = 0  # Track calls for the current block

    for line in lines:
        proc_match = proc_header_re.match(line)
        if proc_match:
            current_proc = proc_match.group(1)
            current_block_calls = 0  # Reset for new block
            continue

        if current_proc:
            metrics_match = metrics_re.match(line)
            extras_match = extras_re.match(line)

            if metrics_match:
                calls = int(metrics_match.group(1))
                min_val = float(metrics_match.group(2))
                avg = float(metrics_match.group(3))
                max_val = float(metrics_match.group(4))
                total_time = float(metrics_match.group(5))

                current_block_calls = calls  # Save for extras line

                agg = aggregated[current_proc]
                agg["calls"] += calls
                agg["total_time"] += total_time
                agg["min"] = min(agg["min"], min_val)
                agg["max"] = max(agg["max"], max_val)
                agg["weighted_avg_sum"] += avg * calls

            if extras_match and current_block_calls > 0:
                p99 = float(extras_match.group(1))
                p95 = float(extras_match.group(2))
                p50 = float(extras_match.group(3))
                sd = float(extras_match.group(4))
                ratio = float(extras_match.group(5))

                agg = aggregated[current_proc]
                # Use the correct block-local call count for weighting
                agg["weighted_p99_sum"] += p99 * current_block_calls
                agg["weighted_p95_sum"] += p95 * current_block_calls
                agg["weighted_p50_sum"] += p50 * current_block_calls
                agg["weighted_sd_sum"] += sd * current_block_calls
                agg["weighted_ratio_sum"] += ratio * current_block_calls

def print_combined_metrics():
    print(">>>>> COMBINED METRICS ACROSS ALL USERS")
    for proc, data in aggregated.items():
        calls = data["calls"]
        if calls == 0:
            continue
        avg = data["total_time"] / calls
        p99 = data["weighted_p99_sum"] / calls
        p95 = data["weighted_p95_sum"] / calls
        p50 = data["weighted_p50_sum"] / calls
        sd = data["weighted_sd_sum"] / calls
        ratio = data["weighted_ratio_sum"] / calls
        print(f">>>>> PROC: {proc}")
        print(f"CALLS: {calls}     MIN: {data['min']:.3f}ms    AVG: {avg:.3f}ms  MAX: {data['max']:.3f}ms TOTAL: {data['total_time']:.3f}ms")
        print(f"P99: {p99:.3f}ms  P95: {p95:.3f}ms  P50: {p50:.3f}ms   SD: {sd:.3f}  RATIO: {ratio:.3f}%\n")

# ====== Example usage =======
if __name__ == "__main__":
    with open(input("Filename: ")) as f:  # Replace with your filename
        content = f.read()
        parse_and_aggregate(content)
        print_combined_metrics()
