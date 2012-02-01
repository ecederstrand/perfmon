import psycopg2

def db_get_id(sql):
    #print sql
    id = None
    dbcon = psycopg2.connect('host=%s dbname=%s user=%s password=%s' 
            %("littlebit.dk", "perfmon", "perfmon", "CHANGETHIS"))
    dbcur = dbcon.cursor()
    dbcur.execute(sql[0])
    result = dbcur.fetchone()
    if result is None:
        dbcur.execute(sql[1])
        id = dbcur.fetchone()[0]
        if id is None:
            id = 1
        else:
            id = int(id)
            id += 1
        dbcur.execute(sql[2] %(id))
        dbcon.commit()
        return id
    else:
        return int(result[0])

def db_insert(sql):
    #print sql
    dbcon = psycopg2.connect('host=%s dbname=%s user=%s password=%s' 
            %("littlebit.dk", "perfmon", "perfmon", "CHANGETHIS"))
    dbcur = dbcon.cursor()
    dbcur.execute(sql)
    dbcon.commit()


class App:
    id = None
    name = None
    revision = None
    conf = None

    def __init__(self, name, revision):
        self.name = name
        self.revision = revision
        self.id = self.get_id()

    def get_id(self):
        sql = []
        sql.append('SELECT id FROM app WHERE name=\''+self.name+'\' AND revision=\''+self.revision+'\'')
        sql.append('SELECT max(id) FROM app')
        sql.append('INSERT INTO app (id, name, revision) VALUES (%i, \''+self.name+'\', \''+self.revision+'\')')
        return db_get_id(sql)


class AppConf:
    id = None
    params = []
    def __init__(self, id):
        self.id = id
    def add_param(self, param, value, filename):
        params.append({'param': param, 'value': value, 'filename': filename })


class AppGroup:
    id = None
    group = []
    def __init__(self):
        pass
    def add_app(self, app, appConf):
        self.group.append([app, appConf])
    def get_id(self):
        sql = []
        sql.append('SELECT id FROM app_group WHERE app_id=\''+str(self.group[0][0].id)+'\' AND app_conf_id=\''+str(self.group[0][1].id)+'\'')
        sql.append('SELECT max(id) FROM app_group')
        sql.append('INSERT INTO app_group (id, app_id, app_conf_id) VALUES (%i, \''+str(self.group[0][0].id)+'\', \''+str(self.group[0][1].id)+'\')')
        self.id = db_get_id(sql)
        return self.id


class OS:
    id = None
    name = None
    branch = None
    cvs_date = None # UTC
    conf = None

    def __init__(self, name, branch, cvs_date):
        self.name = name
        self.branch = branch
        # Convert CVS date format to ISO format
        self.cvs_date = cvs_date[0:4]+"-"+cvs_date[5:7]+"-"+cvs_date[8:10]+" "+cvs_date[11:13]+":"+cvs_date[14:16]+":"+cvs_date[17:19]
        self.id = self.get_id()

    def get_id(self):
        sql = []
        sql.append('SELECT id FROM os WHERE name=\''+self.name+'\' AND branch=\''+self.branch+'\' AND cvs_date_utc=\''+self.cvs_date+'\'')
        sql.append('SELECT max(id) FROM os')
        sql.append('INSERT INTO os (id, name, branch, cvs_date_utc) VALUES (%i, \''+self.name+'\', \''+self.branch+'\', \''+self.cvs_date+'\')')
        return db_get_id(sql)


class OSConf:
    id = None
    params = []
    def __init__(self, id):
        self.id = id
    def add_param(self, param, value, filename):
        params.append({'param': param, 'value': value, 'filename': filename })


class Bench:
    id = None
    name = None
    revision = None
    test_name = None
    conf = None

    def __init__(self, name, revision, test_name):
        self.name = name
        self.revision = revision
        self.test_name = test_name
        self.id = self.get_id()

    def get_id(self):
        sql = []
        sql.append('SELECT id FROM bench WHERE name=\''+self.name+'\' AND revision=\''+self.revision+'\' AND test_name=\''+self.test_name+'\'')
        sql.append('SELECT max(id) FROM bench')
        sql.append('INSERT INTO bench (id, name, revision, test_name) VALUES (%i, \''+self.name+'\', \''+self.revision+'\', \''+self.test_name+'\')')
        return db_get_id(sql)


class BenchConf:
    id = None
    params = []
    def __init__(self, id):
        self.id = id
    def add_param(self, parameter, unit, value):
        params.append({'param': parameter, 'unit': unit, 'value': value })


class Machine:
    id = None
    ip_addr = None
    name = None
    hostname = None
    contact = None
    contact_email = None
    comment = None
    conf = None

    def __init__(self, id):
        self.id = id
 
    def get_id(self):
        return self.id


class MachineConf:
    id = None
    params = []
    def __init__(self, id):
        self.id = id
    def add_param(self, parameter, unit, value):
        params.append({'param': parameter, 'unit': unit, 'value': value })


class Fact:
    #id = None
    machine_id = None
    machine_conf_id = None
    os_id = None
    os_conf_id = None
    bench_id = None
    bench_conf_id = None
    app_group_id = None
    x = None
    dx_pos = -1
    dx_neg = -1
    unit = "None"
    comments = ""

    def save(self):
        sql = ''
        if self.app_group_id is None:
            sql = 'INSERT INTO fact (machine_id, machine_conf_id, os_id, os_conf_id, '\
            +'bench_id, bench_conf_id, x, dx_pos, dx_neg, unit, comments) VALUES '\
            +'(%i, %i, %i, %i, %i, %i, %f, %f, %f, \'%s\', \'%s\')' % \
            (self.machine_id, self.machine_conf_id, self.os_id, self.os_conf_id, \
            self.bench_id, self.bench_conf_id, self.x, self.dx_pos, self.dx_neg, \
            self.unit, self.comments)
        else:
            sql = 'INSERT INTO fact (machine_id, machine_conf_id, os_id, os_conf_id, '\
            +'bench_id, bench_conf_id, app_group_id, x, dx_pos, dx_neg, unit, comments) VALUES '\
            +'(%i, %i, %i, %i, %i, %i, %i, %f, %f, %f, \'%s\', \'%s\')' % \
            (self.machine_id, self.machine_conf_id, self.os_id, self.os_conf_id, \
            self.bench_id, self.bench_conf_id, self.app_group_id, self.x, self.dx_pos, self.dx_neg, \
            self.unit, self.comments)

        db_insert(sql)

