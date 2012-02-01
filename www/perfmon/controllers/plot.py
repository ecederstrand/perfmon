import logging
log = logging.getLogger(__name__)

from perfmon.lib.base import *
from perfmon.model import *

from matplotlib.dates import YearLocator, MonthLocator, DayLocator, HourLocator, DateFormatter, date2num

import PIL, PIL.Image, StringIO, threading, datetime, psycopg2, pylab

import random

imageThreadLock = threading.Lock() # make sure methods for graphics do not overwrite each other


class PlotController(BaseController):

    def index(self):
        # Clear some values in session
        if 'factfirst' in session:
            del session['factfirst']
        if 'factlast' in session:
            del session['factlast']
        # Set defaults
        session['style'] = 'scatter'
        session['errorbars'] = True
        session.save()

        # Get all Benchmark objects from SQLAlchemy
        # Some DB objects are multiple-line. For now, do the "id" workaround

        osbranch_opt = dict()
        osdate_opt_id = list()
        osdate_opt_val = list()
        osconf_opt = dict()
        machine_opt = dict()
        machineconf_opt = dict()
        bench_opt = dict()
        benchconf_opt = dict()

        for o in Session.query(OS).order_by(OS.cvs_date_utc):
            if o.branch.find('CURRENT'):
                osbranch_opt['CURRENT'] = h.content_tag('option', 'CURRENT', value='CURRENT')+'\n'
            else:
                osbranch_opt[o.branch] = h.content_tag('option', o.branch, value=o.branch)+'\n'
            osdate_opt_id.append(o.cvs_date_utc.strftime('%Y.%m.%d.%H.%M.%S'))
            osdate_opt_val.append(o.cvs_date_utc)
        for id, val in osbranch_opt.iteritems():
            c.osbranch_opt += val
        # Make last date selected
        l = len(osdate_opt_id)
        i = 0
        for id, val in zip(osdate_opt_id, osdate_opt_val):
            i += 1
            c.osdatefirst_opt += h.content_tag('option', val, value=id)+'\n'
            if i == l:
                c.osdatelast_opt += h.content_tag('option', val, value=id, selected='selected')+'\n'
            else:
                c.osdatelast_opt += h.content_tag('option', val, value=id)+'\n'

        for o in Session.query(OSConf):
            osconf_opt[o.id] = h.content_tag('option', o.id, value=o.id)+'\n'
        for id, val in osconf_opt.iteritems():
            c.osconf_opt += val
        
        for o in Session.query(Machine):
            machine_opt[o.id] = h.content_tag('option', o.name, value=o.id)+'\n'
        for id, val in machine_opt.iteritems():
            c.machine_opt += val

        for o in Session.query(MachineConf):
            machineconf_opt[o.id] = h.content_tag('option', o.id, value=o.id)+'\n'
        for id, val in machineconf_opt.iteritems():
            c.machineconf_opt += val

        for o in Session.query(Bench):
            bench_opt[o.id] = h.content_tag('option', o.name+' '+o.revision+' ('+o.test_name+')', value=o.id)+'\n'
        for id, val in bench_opt.iteritems():
            c.bench_opt += val

        for o in Session.query(BenchConf):
            benchconf_opt[o.id] = h.content_tag('option', o.id, value=o.id)+'\n'
        for id, val in benchconf_opt.iteritems():
            c.benchconf_opt += val


        # This is to allow the plot to update via AJAX
        # We need a unique URL to trick th browser, since the image
        # is always at the same URL even though it changes.
        # A random number is appended to the URL
        if 'bench' in session:
            c.random = random.randint(1, 1000000)
            c.map = self.map(c.random)
        else:
            c.map = '<area coords="1,1,1" href="#" shape="circle" alt="Default" />'
        
        #response.headers['Content-type'] = 'application/xhtml+xml'
        #config['pylons.response_options']['content_type'] = 'application/xhtml+xml'
        return render('/base.mako')


    def __query(self, sql):
        # Take an SQL statement and return a result object
        dbcon = psycopg2.connect('host=%s dbname=%s user=%s password=%s' 
                %("winther", "perfmon", "perfmon", "itu2008"))
        dbcur = dbcon.cursor()
        dbcur.execute(sql)
        result = dbcur.fetchall()
        dbcur.close()
        dbcon.close()
        return result


    def showbench(self, id):
        session['bench'] = int(id)
        session.save()
        return redirect_to(controller='plot', action='index', id=None)

    def update(self):
        session['osbranch'] = str(request.params.get('osbranch'))
        session['osdatefirst'] = str(request.params.get('osdatefirst'))
        session['osdatelast'] = str(request.params.get('osdatelast'))
        session['osconf'] =  int(request.params.get('osconf'))
        session['machine'] = int(request.params.get('machine'))
        session['machineconf'] = int(request.params.get('machineconf'))
        session['bench'] = int(request.params.get('bench'))
        session['benchconf'] = int(request.params.get('benchconf'))
        session['style'] = str(request.params.get('style'))
        session['errorbars'] = bool(request.params.get('errorbars'))
        session.save()
        c.random = random.randint(1, 1000000)
        c.map = self.map(c.random)
        c.d_facts = 'No datapoint chosen'
        c.d_compare = 'No datapoints chosen'
        c.d_os = self.os(session['osbranch'])
        c.d_osconf = self.osconf(session['osconf'])
        c.d_machine = self.machine(session['machine'])
        c.d_machineconf = self.machineconf(session['machineconf'])
        c.d_bench = self.bench(session['bench'])
        c.d_benchconf = self.benchconf(session['benchconf'])

        return render('/update.mako')


    def zoom(self):
        session['osdatefirst'] = str(request.params.get('osdatefirst'))
        session['osdatelast'] = str(request.params.get('osdatelast'))
        dstart = datetime.datetime.strptime(session['osdatefirst'], '%Y.%m.%d.%H.%M.%S')
        dend = datetime.datetime.strptime(session['osdatelast'], '%Y.%m.%d.%H.%M.%S')
        # Swap the two dates if necessary
        if dstart > dend:
            tmp = session['osdatelast']
            session['osdatelast'] = session['osdatefirst']
            session['osdatefirst'] = tmp
        session.save()
        c.random = random.randint(1, 1000000)
        c.map = self.map(c.random)

        return render('/zoom.mako')

    
    def compare(self):
        dstart = datetime.datetime.strptime(session['factfirst'], '%Y.%m.%d.%H.%M.%S')
        dend = datetime.datetime.strptime(session['factlast'], '%Y.%m.%d.%H.%M.%S')
        if dstart > dend:
            tmp = dstart
            dstart = dend
            dend = tmp
        c.d_compare = '<table><tr><th>Date</th><th>File</th><th>Committer</th><th>Revision</th></tr>\n'
        if session['osbranch']=='CURRENT':
            b = 'HEAD'
        else:
            b= session['osbranch']
        for m in Session.query(CVSLog).filter(CVSLog.date>dstart).filter(CVSLog.date<=dend).filter(CVSLog.branch==b).order_by(CVSLog.date):
            c.d_compare += '<tr><td>%s</td><td><a href="http://www.freebsd.org/cgi/cvsweb.cgi/%s?only_with_tag=MAIN#rev%s">%s</a></td><td>%s</td><td>%s</td></tr>\n' %(m.date, m.filename, m.revision, m.filename, m.committer, m.revision)
        return  h.update_element_function("d_compare", content=str(c.d_compare))

    
    def getfacts(self, id):
        if 'factfirst' in session:
            session['factlast'] = session['factfirst']
            session['factfirst'] = id
        else:
            session['factfirst'] = id
            session['factlast'] = None
        session.save()
        s = '<table><tr><th>Point 1</th><th>Point 2</th></tr><tr>\n'
        if session['factfirst'] is not None:
            s += self.fact(session['factfirst'])
        if session['factlast'] is not None:
            s += self.fact(session['factlast'])+'<td>'
            s += h.form_remote_tag(url=h.url_for(controller='plot', action='compare', id=None), failure=h.update_element_function("d_compare", content="Error when requesting a compare!"), success=h.evaluate_remote_response())
            s += h.hidden_field('factfirst', session['factfirst'])
            s += h.hidden_field('factlast', session['factlast'])
            s += h.submit('Compare')
            s += h.end_form()+'<br />\n'
            s += h.form_remote_tag(url=h.url_for(controller='plot', action='zoom', id=None), failure=h.update_element_function("d_compare", content="Error when requesting a zoom!"), success=h.evaluate_remote_response())
            s += h.hidden_field('osdatefirst', session['factfirst'])
            s += h.hidden_field('osdatelast', session['factlast'])
            s += h.submit('Zoom in')
            return s+'</td></tr></table>'

        return s+'<td></td></tr></table>'

    def fact(self, id):
                
        s = ''
        d = datetime.datetime.strptime(id, '%Y.%m.%d.%H.%M.%S')
        os = Session.query(OS).filter_by(cvs_date_utc=d).one()
        s += '<td>CVS date: %s<br />\n' % (os.cvs_date_utc)
        if 'bench' in session:
            bid = session['bench']
        else:
            bid = 1
        for f in Session.query(Fact).filter_by(os_id=os.id):
            if f.bench_id is bid:
                s += 'Value: %d %s' % (f.x, f.unit)
                if f.dx_pos != -1 and f.dx_neg != -1:
                    s += ' (+/- %d/%d)' % (f.dx_pos, f.dx_neg)
                s += '<br />\n'
        return s+'</td>'

    def os(self, branch):
        s = ''
        if branch == 'CURRENT':
            os = Session.query(OS).filter(OS.branch.like('%CURRENT')).first()
            return s+'%s CURRENT<br />' % (os.name)
        else:
            os = Session.query(OS).filter(OS.branch==branch).first()
            return s+'%s %s<br />' % (os.name, os.branch)

    def osconf(self, id):
        s = '<table><tr><th>File</th><th>Parameter</th><th>Value</th></tr>\n'
        for oc in Session.query(OSConf):
            if oc.id is id:
                s += '<tr><td>%s</td><td>%s</td><td>%s</td></tr>\n' % (oc.filename, oc.param, oc.value)
        return s

    def machine(self, id):
        m = Session.query(Machine).get(id)
        return 'IP addr: %s<br />Name: %s<br />Hostname: %s<br />Contact: %s<br />Email: %s' % (m.ip_addr, m.name, m.hostname, m.contact, m.contact_email)

    def machineconf(self, id):
        s = '<table><tr><th>Parameter</th><th>Value</th><th>Unit</th></tr>\n'
        for mc in Session.query(MachineConf):
            if mc.id is id:
                s += '<tr><td>%s</td><td>%s</td><td>%s</td></tr>\n' % (mc.param, mc.value, mc.unit)
        return s

    def bench(self, id):
        b = Session.query(Bench).get(id)
        return 'Name: %s<br />Revision: %s<br />Test name: %s<br />' % (b.name, b.revision, b.test_name)

    def benchconf(self, id):
        s = '<table><tr><th>Parameter</th><th>Value</th><th>Unit</th></tr>\n'
        for bc in Session.query(BenchConf):
            if bc.id is id:
                s += '<tr><td>%s</td><td>%s</td><td>%s</td></tr>\n' % (bc.param, bc.value, bc.unit)
        return s



    def map(self, id):
        # HTML image coordinates have y=0 on the top.  Matplotlib
        # has y=0 on the bottom.  We'll need to flip the numbers
        dates, xcoords, ycoords = self.png(id, getCoords = True)
        
        if dates is None:
            return '<area coords="1,1,1" href="#" shape="circle" alt="Default" />'

        map = ''
        for d, x, y in zip(dates, xcoords, ycoords):
            dstr = d.strftime('%Y.%m.%d.%H.%M.%S')
            u = h.url_for(controller='plot', action='getfacts', id=dstr)
            js = h.remote_function(update="d_facts", url=u)
            coord = '%d,%d,5' %(x, 500-y)
            map += h.tag('area', shape='circle', coords=coord, onclick=js, href='#', title=dstr)+'\n'

        return map
        

    def __smooth(self, x, window=10):
        s = len(x)
        if s < window:
            return "x is too short"
        r = list()
        h = window // 2
        buffer = x[0:h] # Start by reading in the 5 first values
        i = 0
        for v in x:
            l = len(buffer)
            r.append( sum(buffer) / l )
            if i < (s-h):
                buffer.append(x[i+h])
            if l == window or i >= (s-h):
                buffer.pop(0)
            i += 1
        return r


    def png(self, id = None, getCoords = False):
        # id is discarded. It's just there to trick the browser+AJAX to always get a fresh image
        # This function is called asynchronously (via the img tag in the browser)
        # Therefore, map() must be called (and c.map set) separately

        # make a buffer to hold our data
        buffer = StringIO.StringIO()

        if id is None:
            response.headers['Content-type'] = 'image/png'
            pilImage = PIL.Image.new("RGB", (700, 500), (255, 255, 255))
            pilImage.save(buffer, "PNG") # <-- we will be sending the browser a "PNG file"
            return buffer.getvalue()

        global imageThreadLock # prevent threads from writing over each other's graphics

        # lock graphics
        imageThreadLock.acquire()

        # we don't want different threads to write on each other's canvases, so make sure we have a new one
        pylab.close()

        # get data
        x = []
        y = []
        e = []
        unit = 'No data'
        benchName = 'No data'
        testName = 'No data'
        
        sql  = 'select cvs_date_utc, avg(x), stddev(x), unit, bench.name, test_name from os, fact, bench where os.id=os_id and bench_id=bench.id '
        if 'osbranch' in session:
            if session['osbranch'] == 'CURRENT':
                sql += "and branch like '%s' " %('%CURRENT')
            else:
                sql += "and branch='%s' " %(session['osbranch'])
        if 'osdatefirst' in session:
            sql += "and cvs_date_utc>='%s' " %(datetime.datetime.strptime(session['osdatefirst'], '%Y.%m.%d.%H.%M.%S'))
        if 'osdatelast' in session:
            sql += "and cvs_date_utc<='%s' " %(datetime.datetime.strptime(session['osdatelast'], '%Y.%m.%d.%H.%M.%S'))
        if 'osconf' in session:
            sql += 'and os_conf_id=%d ' %(session['osconf'])
        if 'machine' in session:
            sql += 'and machine_id=%d ' %(session['machine'])
        if 'machineconf' in session:
            sql += 'and machine_conf_id=%d ' %(session['machineconf'])
        if 'bench' in session:
            sql += 'and bench_id=%d ' %(session['bench'])
        else:
            sql += 'and bench_id=%d ' %(1) # We need some default
        if 'benchconf' in session:
            sql += 'and bench_conf_id=%d ' %(session['benchconf'])
        sql += 'group by cvs_date_utc, unit, bench.name, test_name order by cvs_date_utc;'

        result = self.__query(sql)
 
        if len(result) is 0:
            if getCoords is True:
                # unlock graphics
                imageThreadLock.release()
                return datetime.datetime.now(), x, y
            else:
                x.append(datetime.datetime.now())
                y.append(1)
                e.append(0)
        else:
            for fact in result:
                x.append(fact[0])           # date
                y.append(fact[1])           # float
                if fact[2] is None:
                    e.append(0)             # float
                else:
                    e.append(3*fact[2])     # float
                unit = str(fact[3])         # string
                benchName = str(fact[4])    # string
                testName = str(fact[5])     # string
        
        begindate = result[0][0]
        enddate = result[len(result)-1][0]
        timespan = enddate - begindate
        margin = timespan // 20 # Add a 5% margin at both ends. Y-axes seem OK.
        begindate -= margin
        enddate += margin
        timespan = enddate - begindate

        # 700x500 pixels
        figure = pylab.figure(figsize=(8.75,6.25), dpi=80, frameon=False)

        plot = figure.add_subplot(111)
        #ax = figure.add_axes((0,0,1,1))
        
        # quick simple scatter plot and error bars
        if 'errorbars' in session:
            if session['errorbars'] is True:
                plot.errorbar(date2num(x), y, e, ls='None', label='_nolegend_', zorder=0)
        if 'style' in session:
            if session['style'] == 'smooth':
                plot.plot(date2num(x), self.__smooth(y), zorder=1)
                sc = None
            else:
                sc = plot.scatter(date2num(x), y, c='r', label='_nolegend_', zorder=2)
        else:
            sc = plot.scatter(date2num(x), y, c='r', label='_nolegend_', zorder=2)
        #pylab.axvline(x=result[30][0], label='7.0 RELEASE')
        
        pylab.gca().set_xlim([begindate, enddate])          # set xaxis limits
        
        # format the ticks
        # We want about 10 date ticks
        if timespan.days < 5:
            #Show hours
            if timespan < datetime.timedelta(1):
                locator = HourLocator(interval=1)    # every 1 hours
            else:
                locator = HourLocator(interval=((timespan // 10).seconds) // 3600)
            fmt = DateFormatter('%Y.%m.%d.%H.%M.%S')

        else:
            if timespan.days < 12:
                locator = DayLocator(interval=1)    # every 1 days
            else:
                locator = DayLocator(interval=(timespan.days // 10))
            fmt = DateFormatter('%Y.%m.%d')


        plot.xaxis.set_major_locator(locator)
        plot.xaxis.set_major_formatter(fmt)
        plot.xaxis.set_minor_locator(locator)

        # Adjust font size. Ugly :-(
        fontsize=8
        for tick in plot.xaxis.get_major_ticks():
            tick.label1.set_fontsize(fontsize)
        for tick in plot.yaxis.get_major_ticks():
            tick.label1.set_fontsize(fontsize)

        figure.autofmt_xdate()

        plot.set_xlabel('CVS date (UTC)')
        plot.set_ylabel(unit)
        plot.set_title(benchName+' ('+testName+')')

        # The final plot has been constructed. If told to do so, get coordinates
        if getCoords:
            if sc is None:
                imageThreadLock.release()
                return None, None, None
            # Convert the data set points into screen space coordinates
            trans = sc.get_transform()
            xcoords, ycoords = trans.seq_x_y(date2num(x), y)
            # unlock graphics
            imageThreadLock.release()
            return x, xcoords, ycoords
        
        # set the response type to PNG, since we at least hope to return a PNG image here
        response.headers['Content-Type'] = 'image/png'

        pylab.canvas = pylab.get_current_fig_manager().canvas
        pylab.canvas.draw()
        imageSize = pylab.canvas.get_width_height()
        imageRgb = pylab.canvas.tostring_rgb()
        pilImage = PIL.Image.fromstring("RGB", imageSize, imageRgb)

        pilImage.save(buffer, "PNG") # <-- we will be sending the browser a "PNG file"

        # unlock graphics
        imageThreadLock.release()

        return buffer.getvalue()

