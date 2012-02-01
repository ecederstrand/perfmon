import os
import re
import time
from datamodel import *

# This is a generic benchmark object
class Benchmark:
    name = None
    version = None
    facts = []
    def __init__(self):
        pass # E.g. set up internal data structures
    def pre(self):
        pass # E.g. configure benchmark, and configure and start dependent apps
    def run(self):
        pass # Run the benchmark and collect the data
    def post(self):
        pass # Clean up, format data, shut down apps etc.


class SuperSmack(Benchmark):
    def __init__(self):
        self.name = 'super-smack'
        self.version = os.popen('pkg_info -Ix '+self.name+' | awk \'{ print $1 }\' | sed \'s/^'+self.name+'-//\' | tr -d \'\n\'').read()
    def pre(self):
        # super-smack needs /usr/local/bin/gen-data
        # When run from rc.local, the path there is not sufficient
        # Therefore, we symlink gen-data to a location in the limited path
        os.system('ln -s /usr/local/bin/gen-data /bin/gen-data')

        os.system('echo "mysql_enable=\"YES\"" >> /etc/rc.conf')
        os.system('/usr/local/etc/rc.d/mysql-server start')
        time.sleep(5) # Give mysql time to start up
        
        os.system('echo "create user test;" | /usr/local/bin/mysql -u root mysql')
        mysql_version =  os.popen('pkg_info -Ix mysql-server | awk \'{ print $1 }\' | sed \'s/^mysql-server-//\' | tr -d \'\n\'').read()
        mysql = App('mysql-server', mysql_version)
        mysql_conf = AppConf(1) # Hardcoded to database ID=1
        self.group = AppGroup()
        self.group.add_app(mysql, mysql_conf)
        self.app_group_id = self.group.get_id()
    def run(self):
        for i in range(1,10):
            test_name1 = 'select-key, '+str(i)+' clients'
            b1 = Bench(self.name, self.version, test_name1)
            for j in range(10):
                f = Fact()
                f.x = float(os.popen('/usr/local/bin/super-smack -d mysql /usr/local/share/super-smack/select-key.smack '+str(i)+' 1000 | grep \'select\' | awk \'{print $5}\' | tr -d \'\n\'').read())
                f.unit = 'queries/s'
                f.bench_id = b1.id
                f.app_group_id = self.app_group_id
                self.facts.append(f)
            test_name2 = 'update-select, '+str(i)+' clients'
            b2 = Bench(self.name, self.version, test_name2)
            for j in range(10):
                f = Fact()
                f.x = float(os.popen('/usr/local/bin/super-smack -d mysql /usr/local/share/super-smack/update-select.smack '+str(i)+' 1000 | grep \'update\' | awk \'{print $5}\' | tr -d \'\n\'').read())
                f.unit = 'queries/s'
                f.bench_id = b2.id
                f.app_group_id = self.app_group_id
                self.facts.append(f)
    def post(self):
        os.system('echo "drop user test" | /usr/local/bin/mysql -u root mysql')
        os.system('/usr/local/etc/rc.d/mysql-server stop')
        os.system('rm /bin/gen-data')
            


class UnixBench(Benchmark):
    def __init__(self):
        self.name = 'unixbench'
        self.version = os.popen('pkg_info -Ix '+self.name+' | awk \'{ print $1 }\' | sed \'s/^'+self.name+'-//\' | tr -d \'\n\'').read()
    def run(self):
        self.data = os.popen('/usr/local/bin/unixbench').read()
        self.data = self.data.split('\n')
        count = 0
        for line in self.data:
            count += 1
            if count < 69:
                continue
            elif count > 96:
                break
            else:
                line = re.sub('[ ]{2,99}', '|', line).split('|')
                test_name = line[0]
                b = Bench(self.name, self.version, test_name)
                
                line = line[1].split(' ')
                value = float(re.sub(',', '.', line[0])) # Typecast string to float, change , to .
                unit = line[1]
                f = Fact()
                f.x = value
                f.unit = unit
                f.bench_id = b.id
                self.facts.append(f)

