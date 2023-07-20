import logging
from tinyben import TinyBen
from benchmarks.godot import TBGodotBenchmark
from benchmarks.imagemagick import TBImageMagickBenchmark
from benchmarks.linux import TBLinuxBenchmark
from benchmarks.llvm import TBLlvmBenchmark
from benchmarks.lz4 import TBLz4Benchmark
from benchmarks.mbw import TBMbwBenchmark
from benchmarks.redis import TBRedisBenchmark
from benchmarks.sqlite import TBSqliteBenchmark
from benchmarks.tinymembench import TBTinymembenchBenchmark

FORMAT = "[%(asctime)s] {%(pathname)s:%(lineno)d} %(levelname)s  - %(message)s"
logging.basicConfig(level=logging.DEBUG, format=FORMAT)

tb = TinyBen()
tb.add_benchmark(TBGodotBenchmark())
tb.add_benchmark(TBImageMagickBenchmark())
tb.add_benchmark(TBLinuxBenchmark())
tb.add_benchmark(TBLlvmBenchmark())
tb.add_benchmark(TBMbwBenchmark())
tb.add_benchmark(TBRedisBenchmark())
tb.add_benchmark(TBSqliteBenchmark())
tb.add_benchmark(TBTinymembenchBenchmark())
tb.run()
tb.print_results()
