import subprocess


def run_fio_test(name, machine, filename, direct, iodepth, rw, bs, numjobs, output):
    name = f"{machine}-{rw}-direct-{direct}-{bs}-{numjobs}-{iodepth}"
    command = [
        "fio",
        "--name=" + name,
        "--filename=" + filename,
        "--direct=" + str(direct),
        "--iodepth=" + str(iodepth),
        "--rw=" + rw,
        "--bs=" + bs,
        "--numjobs=" + str(numjobs),
        "--runtime=30",
        "--output-format=json",
        "--output=" + name + ".json",
    ]
    subprocess.run(command)


# Test configurations
tests = [
    {
        "direct": 1,
        "filename": "/dev/nvme0n1",
        "iodepth": 128,
        "rw": "randread",
        "bs": "4k",
        "numjobs": 4,
    },
]

# Execute the tests
for test in tests:
    run_fio_test(machine="baremetal", **test)


# Case name (bs,rw,numjobs,iodepth)

# randread-4k-4-128 (4k,randread, 4,128)

# randwrite-4k-4-128 (4k,ranwrite, 4,128)
# seqread-128k-4-128 (128k,read,4,128)
# seqwrite-128k-4-128 (128k,write,4,128)

# randread-4k-1-1 (4k,randread,1,1)
# randwrite-4k-1-1 (4k,randwrite,1,1)
# seqread-4k-1-1 (4k,read,1,1)
# seqwrite-4k-1-1 (4k,write,1,1)
