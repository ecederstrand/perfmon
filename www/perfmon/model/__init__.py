from pylons import config
from sqlalchemy import MetaData, Table
from sqlalchemy.orm import mapper
from sqlalchemy.orm import scoped_session, sessionmaker

Session = scoped_session(sessionmaker(autoflush=True, transactional=True,
                                      bind=config['pylons.g'].sa_engine))

metadata = MetaData()
metadata.bind = config['pylons.g'].sa_engine

app_table = Table('app', metadata, autoload=True)
app_conf_table = Table('app_conf', metadata, autoload=True)
app_group_table = Table('app_group', metadata, autoload=True)
bench_table = Table('bench', metadata, autoload=True)
bench_conf_table = Table('bench_conf', metadata, autoload=True)
machine_table = Table('machine', metadata, autoload=True)
machine_conf_table = Table('machine_conf', metadata, autoload=True)
os_table = Table('os', metadata, autoload=True)
os_conf_table = Table('os_conf', metadata, autoload=True)
fact_table = Table('fact', metadata, autoload=True)
cvs_log_table = Table('cvs_log', metadata, autoload=True)

class App(object):
    def __str__(self):
        return str(self.id)

class AppConf(object):
    def __str__(self):
        return str(self.id)

class AppGroup(object):
    def __str__(self):
        return str(self.id)

class Bench(object):
    def __str__(self):
        return str(self.id)

class BenchConf(object):
    def __str__(self):
        return str(self.id)

class Machine(object):
    def __str__(self):
        return str(self.id)

class MachineConf(object):
    def __str__(self):
        return str(self.id)

class OS(object):
    def __str__(self):
        return str(self.id)

class OSConf(object):
    def __str__(self):
        return str(self.id)

class Fact(object):
    def __str__(self):
        return str(self.id)

class CVSLog(object):
    def __str__(self):
        return str(self.id)


mapper(App, app_table)
mapper(AppConf, app_conf_table)
mapper(AppGroup, app_group_table)
mapper(Bench, bench_table)
mapper(BenchConf, bench_conf_table)
mapper(Machine, machine_table)
mapper(MachineConf, machine_conf_table)
mapper(OS, os_table)
mapper(OSConf, os_conf_table)
mapper(Fact, fact_table)
mapper(CVSLog, cvs_log_table)

