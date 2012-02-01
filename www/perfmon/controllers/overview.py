import logging
log = logging.getLogger(__name__)

from perfmon.lib.base import *
from perfmon.model import *

from matplotlib.dates import YearLocator, MonthLocator, DayLocator, HourLocator, DateFormatter, date2num

import PIL, PIL.Image, StringIO, threading, datetime, psycopg2, pylab

imageThreadLock = threading.Lock() # make sure methods for graphics do not overwrite each other


class OverviewController(BaseController):

    def index(self):
        # Get all Benchmark objects from SQLAlchemy
        c.benchids = list()

        for o in Session.query(Bench):
            c.benchids.append(o.id)

        return render('/overview.mako')


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


    def generate(self):
        # Get all Benchmark objects from SQLAlchemy
        for o in Session.query(Bench):
            self.__png(o.id)
        return "Thumbnail generation completed."


    def __png(self, id = None):
        # This function is only called by generate()
        if id is None:
            response.headers['Content-type'] = 'image/png'
            pilImage = PIL.Image.new("RGB", (140, 100), (255, 255, 255))
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
        sql += "and branch like '%s' " %('%CURRENT')
        sql += 'and os_conf_id=%d ' %(1)
        sql += 'and machine_id=%d ' %(1)
        sql += 'and machine_conf_id=%d ' %(1)
        sql += 'and bench_id=%d ' %(int(id))
        sql += 'and bench_conf_id=%d ' %(1)
        sql += 'group by cvs_date_utc, unit, bench.name, test_name order by cvs_date_utc;'

        result = self.__query(sql)
 
        if len(result) is 0:
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
        figure = pylab.figure(figsize=(5,4), dpi=60, frameon=False)

        plot = figure.add_subplot(111)
        #ax = figure.add_axes((0,0,1,1))
        
        # quick simple scatter plot
        sc = plot.scatter(date2num(x), y, c='r')
        plot.errorbar(x, y, e, ls='None')

        a = pylab.gca()
        a.set_xlim([begindate, enddate])          # set xaxis limits

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

        pylab.canvas = pylab.get_current_fig_manager().canvas
        pylab.canvas.draw()
        imageSize = pylab.canvas.get_width_height()
        imageRgb = pylab.canvas.tostring_rgb()
        pilImage = PIL.Image.fromstring("RGB", imageSize, imageRgb)

        pilImage.save('perfmon/public/img/thunmbnails/%s.png' %id, "PNG")

        # unlock graphics
        imageThreadLock.release()

