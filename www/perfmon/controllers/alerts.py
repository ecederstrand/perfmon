import logging
log = logging.getLogger(__name__)

from perfmon.lib.base import *
from perfmon.model import *

import datetime, psycopg2, operator, shelve
from math import sqrt

class AlertsController(BaseController):

    def index(self):
        db = shelve.open('perfmon/public/alerts')
        if 'alerts' not in db:
            db.close()
            self.generate()
            db = shelve.open('perfmon/public/alerts')
        c.alerts = db['alerts']
        db.close()

        return render('/alerts.mako')


    def generate(self):
        # Get all Benchmark objects from SQLAlchemy
        alerts = list()
        for o in Session.query(Bench):
            dates, changes = self.__find(o.id)
            for d, p in zip(dates, changes):
                # Don't issue warnings on changes less than 0.5%
                if abs(p) > 0.01:
                    alerts.append((d, o.id, o.name, o.revision, o.test_name, p))
        
        alerts = sorted(alerts, key=operator.itemgetter(0))
        db = shelve.open('perfmon/public/alerts')
        db['alerts'] = alerts
        db.close()
        return "Alert generation completed"

    def show(self, id):
        c.alerts = list()
        o = Session.query(Bench).get(id)
        dates, changes = self.__find(o.id)
        for d, p in zip(dates, changes):
            # Don't issue warnings on changes less than 0.5%
            if abs(p) > 0.01:
                c.alerts.append((d, o.id, o.name, o.revision, o.test_name, p))
        return render('/alerts.mako')


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


    def __stddev(self, window):
        # Cannot compute stddev on one value
        if len(window) == 1:
            return 0, window[0]
        # Combined estimated standard deviation
        # Expects a list of lists and values >=0
        def square(x): return x*x
        
        mean = sum(window) / len(window)

        def diff(x): return x-mean
        return sqrt( sum( map( square, map( diff, window) )) / ( len(window) - 1) ), mean


    def __add(self, x, y):
        return x+y


    def __find(self, id = None):
        # Define a sliding window of 10 dates of data points and generate an alert if the following data point 
        # is outside 3*standard deviation
        sql  = 'select cvs_date_utc, x from os, fact, bench where os.id=os_id and bench_id=bench.id '
        sql += "and branch like '%s' " %('%CURRENT')
        sql += 'and os_conf_id=%d ' %(1)
        sql += 'and machine_id=%d ' %(1)
        sql += 'and machine_conf_id=%d ' %(1)
        sql += 'and bench_id=%d ' %(int(id))
        sql += 'and bench_conf_id=%d ' %(1)
        sql += 'order by cvs_date_utc;'

        result = self.__query(sql)

        if len(result) is 0:
            return 'No data'
        else:
            # WARNING: does not give an alert on the very last date
            queue = list() # Stores facts in the window. Stores 10 dates + 1 upcoming date
            alertcounter = 0 # Saves result of previous calculation. We don't want to collect alerts on 10 dates in a row
            prevdate = datetime.datetime.now() # Needed to check if current fact is part of many measurements on th same day
            queuecounter = list() # Stores the number of facts by date in the queue
            alerts = list() # List of dates to look more closely at
            changes = list() # Relative change at alerts
            alertdate = None
            for fact in result:
                if prevdate != fact[0]:
                    # Don't calculate deviations when queue is not yet full
                    if len(queuecounter) == 11:
                        i = queuecounter[10] # Number of facts with latest date
                        n = len(queue)
                        #Currently, no points have a stddev. Calculate from first 7 days of point data instead
                        sd, mean = self.__stddev(queue[0:n-i])
                        # Test for 3 * standard deviation on facts with latest date
                        facts = queue[n-i:n]
                        fstddev, fmean = self.__stddev(facts)
                        if fmean > (mean + 2*sd) or fmean < (mean - 2*sd):
                            # This point is outside the sliding window boundaries
                            alertcounter += 1
                            if alertcounter == 1:
                                alertdate = prevdate  # Save date of first occurrence
                            # Weed out single stray points
                            if alertcounter == 2:
                                alerts.append(alertdate) # date
                                changes.append((fmean - mean)/mean)
                        else:
                            alertcounter = 0
                        # Remove facts with oldest dates
                        for x in range(queuecounter[0]):
                            queue.pop(0)
                        queuecounter.pop(0) # Remove counter for oldest date
                    queuecounter.append(0) # Add counter for new date
                    # We changed to a new date
                    prevdate = fact[0]
                # Add fact to queue and raise counter
                queue.append(fact[1])       # float
                queuecounter[-1] += 1
            return alerts, changes
