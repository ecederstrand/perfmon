from mako import runtime, filters, cache
UNDEFINED = runtime.UNDEFINED
_magic_number = 2
_modified_time = 1201049379.0404029
_template_filename=u'/usr/local/www/perfmon/trunk/perfmon/templates/details.mako'
_template_uri=u'/details.mako'
_template_cache=cache.Cache(__name__, _modified_time)
_source_encoding=None
_exports = []


def render_body(context,**pageargs):
    context.caller_stack.push_frame()
    try:
        __M_locals = dict(pageargs=pageargs)
        # SOURCE LINE 1
        context.write(u'<div id="d_details">\n<h2>OS</h2>\n<div id="d_os"></div>\n<h2>OS Conf</h2>\n<div id="d_osconf"></div>\n<h2>Machine</h2>\n<div id="d_machine"></div>\n<h2>Machine Conf</h2>\n<div id="d_machineconf"></div>\n<h2>Benchmark</h2>\n<div id="d_bench"></div>\n<h2>Benchmark Conf</h2>\n<div id="d_benchconf"></div>\n</div>\n')
        return ''
    finally:
        context.caller_stack.pop_frame()


