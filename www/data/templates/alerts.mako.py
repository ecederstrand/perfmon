from mako import runtime, filters, cache
UNDEFINED = runtime.UNDEFINED
_magic_number = 2
_modified_time = 1201371826.2983339
_template_filename='/usr/local/www/perfmon/trunk/perfmon/templates/alerts.mako'
_template_uri='/alerts.mako'
_template_cache=cache.Cache(__name__, _modified_time)
_source_encoding=None
_exports = []


def render_body(context,**pageargs):
    context.caller_stack.push_frame()
    try:
        __M_locals = dict(pageargs=pageargs)
        h = context.get('h', UNDEFINED)
        c = context.get('c', UNDEFINED)
        # SOURCE LINE 1
        runtime._include_file(context, u'/header.mako', _template_uri)
        context.write(u'\n        <div class="box" id="alerts">\n            <h1>Alerts</h1>\n    ')
        # SOURCE LINE 4

        cells = ''
        prevdate = None
        n = len(c.alerts)
        i = 0
        for a in c.alerts:
            date = a[0]
            diff = a[5]
            i += 1
            if i == 1:
                cells += '<tr><td>%s</td><td>' % date
                prevdate = date
            elif date != prevdate:
                cells += '</td></tr>\n<tr><td>%s</td><td>' % date
                prevdate = date
        
            if diff > 0:
                status = "improvement"
            else:
                status = "regression"
            # Colors range from 150 to 0
            # This was hound empirically. Colors max out at 25% change
            color = 150 - abs(int(diff * 600))
            if color < 0:
                color = 0
            if diff < 0:
                # Shade of red
                hexcol = "#FF%02X%02X" % (color, color)
            else:
                # Shade of green
                hexcol = "#%02XFF%02X" % (color, color)
            u = h.url_for(controller='plot', action='showbench', id=a[1])
            div = h.content_tag('div', '%.2f%%  - %s v.%s (%s)<br />' %(diff*100, a[2], a[3], a[4]), style='background-color: %s;' % hexcol)
            cells += h.content_tag('a', div, href=u)
            if i == n:
                cells += '</td></tr>\n'
        
        
        __M_locals.update(dict([(__M_key, locals()[__M_key]) for __M_key in ['a','status','hexcol','i','cells','n','color','prevdate','u','date','diff','div'] if __M_key in locals()]))
        # SOURCE LINE 40
        context.write(u'\n            <table><tr><th>Date</th><th>Change</th></tr>\n            ')
        # SOURCE LINE 42
        context.write(unicode(cells))
        context.write(u'\n            </table>\n        </div>\n\t\t')
        # SOURCE LINE 45
        runtime._include_file(context, u'/footer.mako', _template_uri)
        context.write(u'\n')
        return ''
    finally:
        context.caller_stack.pop_frame()


