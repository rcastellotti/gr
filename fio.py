import subprocess

def run_fio_test(machine, filename, iodepth, rw, bs, numjobs):
    name = f"{machine}-{rw}-{bs}-{numjobs}-{iodepth}"
    command = [
        "fio",
        "--name=" + name,
        "--filename=" + filename,
        "--iodepth=" + str(iodepth),
        "--rw=" + rw,
        "--size=1G",
        "--bs=" + bs,
        "--numjobs=" + str(numjobs),
        "--runtime=30",
        "--output-format=json",
        "--output=" + name + ".json",
    ]
    subprocess.run(command)


# Test configurations
tests = [
    {"iodepth": 128,"rw": "randread","bs": "4k","numjobs": 4},
    {"iodepth": 128,"rw": "randwrite","bs": "4k","numjobs": 4},
    {"iodepth": 128,"rw": "read","bs": "128k","numjobs": 4},
    {"iodepth": 128,"rw": "write","bs": "128k","numjobs": 4},   
    {"iodepth": 1,"rw": "randread","bs": "4k","numjobs": 4},
    {"iodepth": 1,"rw": "randwrite","bs": "4k","numjobs": 4,},
    {"iodepth": 1,"rw": "read","bs": "4k","numjobs": 1},
    {"iodepth": 1,"rw": "write","bs": "4k","numjobs": 1},
]

for test in tests:
    run_fio_test(**test, machine="baremetal", filename="/mnt/a")
