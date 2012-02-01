import os
import time

from Perfmon.datamodel import *
from Perfmon.benchmarks import *

# Define this machine. Currently hardcoded to database ID=1
pm_machine = Machine(1)
pm_machine.conf = MachineConf(1)

# Get the characteristics of this OS
name = os.popen('sysctl -n kern.ostype | tr -d \'\n\'').read()
branch = os.popen('sysctl -n kern.osrelease | tr -d \'\n\'').read()
cvs_date = os.popen('cat /etc/cvs_date | tr -d \'\n\'').read()
pm_os = OS(name, branch, cvs_date)
pm_os.conf = OSConf(1) # Hardcoded to database ID=1

print 'This is '+name+' '+branch+' CVS date '+cvs_date

bench_list = []
ss = SuperSmack()
bench_list.append(ss)
ub = UnixBench()
bench_list.append(ub)

bc = BenchConf(1) # Hardcoded to database ID=1

for b in bench_list:
    print time.ctime()+': Preparing to run '+b.name
    b.pre()
    print time.ctime()+': Running '+b.name
    b.run()
    print time.ctime()+': Cleaning up after '+b.name
    b.post()
    for fact in b.facts:
        fact.machine_id = pm_machine.id
        fact.machine_conf_id = pm_machine.conf.id
        fact.os_id = pm_os.id
        fact.os_conf_id = pm_os.conf.id
        # fact.bench_id is already set
        fact.bench_conf_id = bc.id
        # fact.app_group_id is already set
        fact.save()
    del b

print 'done'
