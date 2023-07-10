import subprocess

def run_fio_test(machine,group, testcase, iodepth, rw, bs, numjo"bs"):

    name = f"{machine}-{group}-{testcase}"
    print(f"running benchmark: {name}")
    command = [
        "fio",
        "--name=" + name,
        "--filename=" + filename,
        "--iodepth=" + str(iodepth),
        "--rw=" + rw,
        "--size=1G",
        "--"bs"=" + "bs",
        "--numjo"bs"=" + str(numjo"bs"),
        "--runtime=30",
        "--output-format=json",
        "--direct=1",
        "--output=" name + ".json",
    ]
    subprocess.run(command)



tests=[
    {"group":"bandwidth","testcase":"read","bs":"128K","rw":"read","iodepth":"128","numjobs":"1"},
    {"group":"bandwidth","testcase":"write","bs":"128K","rw":"write","iodepth":"128","numjobs":"1"},
    {"group":"IOPS","testcase":"randread","bs":"4K","rw":"randread","iodepth":"32","numjobs":"4"},
    {"group":"IOPS","testcase":"mixread","bs":"4K","rw":"randread 70%","iodepth":"32","numjobs":"4"},
    {"group":"IOPS","testcase":"mixwrite","bs":"4K","rw":"randwrite 30%","iodepth":"32","numjobs":"4"},
    {"group":"IOPS","testcase":"randwrite","bs":"4K","rw":"randread","iodepth":"32","numjobs":"4"},
    {"group":"IOPS","testcase":"randwrite","bs":"4K","rw":"randread","iodepth":"32","numjobs":"4"},
    {"group":"average_latency","testcase":"randread","bs":"4K","rw":"randread","iodepth":"1","numjobs":"1"},
    {"group":"average_latency","testcase":"randwrite","bs":"4K","rw":"randwrite","iodepth":"1","numjobs":"1"},
    {"group":"average_latency","testcase":"read","bs":"4K","rw":"read","iodepth":"1","numjobs":"1"},
    {"group":"average_latency","testcase":"write","bs":"4K","rw":"write","iodepth":"1","numjobs":"1"}


]

for test in tests:
    run_fio_test(**test, machine="baremetal", filename="/mnt/a")
    # run_fio_test(**test, machine="scsi-sev", filename="/mnt/a")
    # run_fio_test(**test, machine="blk-sev", filename="/mnt/a")
    # run_fio_test(**test, machine="nvme-sev", filename="/mnt/a")
    # run_fio_test(**test, machine="scsi-nosev", filename="/mnt/a")
    # run_fio_test(**test, machine="blk-nosev", filename="/mnt/a")
    # run_fio_test(**test, machine="nvme-nosev", filename="/mnt/a")∏ssh