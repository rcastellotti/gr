"""
This module contains the base TBBenchmark class benchmarks extends
"""
import logging
import abc


class TBBenchmarkBase(metaclass=abc.ABCMeta):
    """base TBBenchmark class benchmarks extends"""

    result=""
    """base class for TBBenchmarks"""

    @abc.abstractmethod
    def pre(self):
        """method to setup the benchmark"""
        raise NotImplementedError

    @abc.abstractmethod
    def run_benchmark(self):
        """method that actually runs the benchmark"""
        raise NotImplementedError

    def run(self):
        """method introduced to add logging and call `pre` and `post` methods"""
        logging.debug(f"start pre {self.result._benchmark_fullname}")
        self.pre()
        logging.debug(f"completed pre {self.result._benchmark_fullname}")

        logging.debug(f"start running benchmark {self.result._benchmark_fullname}")
        self.run_benchmark()
        logging.debug(f"completed running benchmark {self.result._benchmark_fullname}")

        logging.debug(f"start post {self.result._benchmark_fullname}")
        self.post()
        logging.debug(f"completed post {self.result._benchmark_fullname}")

    @abc.abstractmethod
    def post(self):
        """method to cleanup the benchmark"""
        raise NotImplementedError

    @classmethod
    def __subclasshook__(cls, subclass):
        return (
            hasattr(subclass, "pre")
            and callable(subclass.pre)
            and hasattr(subclass, "post")
            and callable(subclass.post)
            and hasattr(subclass, "run_benchmark")
            and callable(subclass.run_benchmark)
            or NotImplemented
        )
