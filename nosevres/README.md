# tinyben

tinyben is an attempt to create a bencharking suite, similar to [phoronix-test-suite](https://www.phoronix-test-suite.com/), but simpler and easier to use. tinyBen is designed to ben <1000 lines of code [1](https://github.com/geohot/minikeyvalue).

We are always supporting (at least) the latest Ubuntu LTS version.

## usage

```bash
python3 -m venv venv
pip3 install -r requirements.txt
python3 run.py 
```
If you need to run with root permission (`apt-get` is part of a benchmark) run instead `sudo venv/bin/python3 runner.py`

https://github.com/rcastellotti/tinyben/blob/6cc00939da60bbf2cf6a6a01fc267c9609f7b078/run.py#L1-L27

## sample run output

![image](https://github.com/rcastellotti/tinyben/assets/43064224/004ce34b-a4f8-4b40-99f9-7d103813182d)
