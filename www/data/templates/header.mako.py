from mako import runtime, filters, cache
UNDEFINED = runtime.UNDEFINED
_magic_number = 2
_modified_time = 1201377748.842088
_template_filename=u'/usr/local/www/perfmon/trunk/perfmon/templates/header.mako'
_template_uri=u'/header.mako'
_template_cache=cache.Cache(__name__, _modified_time)
_source_encoding=None
_exports = []


def render_body(context,**pageargs):
    context.caller_stack.push_frame()
    try:
        __M_locals = dict(pageargs=pageargs)
        h = context.get('h', UNDEFINED)
        # SOURCE LINE 1
        context.write(u'<?xml version="1.0" encoding="utf-8"?>\n<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">\n<html xmlns="http://www.w3.org/1999/xhtml">\n<head>\n  <title>FreeBSD PerfMon Project</title>\n  <meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />\n  ')
        # SOURCE LINE 7
        context.write(unicode(h.javascript_include_tag(builtins=True)))
        context.write(u'\n  <link rel="stylesheet" type="text/css" href="/style.css" />\n</head>\n<body>\n<script type=\'text/javascript\'>\nfunction toggle(id){\n    var tmp = document.getElementById(id)\n    if (tmp.style.display == \'none\') {\n        tmp.style.display = \'block\'\n    } else {\n        tmp.style.display = \'none\'\n    }   \n}\n</script>\n        <div id="header">\n            <h1><a href="/plot">FreeBSD PerfMon Project</a></h1>\n            <p><a href="/plot">Search</a> \n             &nbsp;&nbsp; | &nbsp;&nbsp;<a href="/overview">Overview</a> \n             &nbsp;&nbsp; | &nbsp;&nbsp;<a href="/alerts">Alerts</a> \n             &nbsp;&nbsp; | &nbsp;&nbsp;<a href="http://tinderbox.des.no/">Tinderbox</a> \n             &nbsp;&nbsp; | &nbsp;&nbsp;<a href="http://people.freebsd.org/~pho/stress/log/index.html">Stress Test</a> \n             &nbsp;&nbsp; | &nbsp;&nbsp;<a href="http://portsmon.freebsd.org/">Portsmon</a>\n             &nbsp;&nbsp; | &nbsp;&nbsp;<a href="http://pointyhat.freebsd.org/errorlogs/">Pointyhat</a>\n             &nbsp;&nbsp; | &nbsp;&nbsp;<a href="http://sources.zabbadoz.net/freebsd/lor.html">LOR</a>\n             &nbsp;&nbsp; | &nbsp;&nbsp;<a href="#">About</a></p>\n         </div>\n\n')
        return ''
    finally:
        context.caller_stack.pop_frame()


