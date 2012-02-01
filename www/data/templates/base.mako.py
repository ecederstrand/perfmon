from mako import runtime, filters, cache
UNDEFINED = runtime.UNDEFINED
_magic_number = 2
_modified_time = 1201329286.7861121
_template_filename='/usr/local/www/perfmon/trunk/perfmon/templates/base.mako'
_template_uri='/base.mako'
_template_cache=cache.Cache(__name__, _modified_time)
_source_encoding=None
_exports = []


def render_body(context,**pageargs):
    context.caller_stack.push_frame()
    try:
        __M_locals = dict(pageargs=pageargs)
        # SOURCE LINE 1
        runtime._include_file(context, u'/header.mako', _template_uri)
        context.write(u'\n        <div id="left">\n                <div class="box" id="control">\n                        <h1>Control</h1>\n                        <a class="toggle" href="javascript: toggle(\'d_control\');">hide</a>\n\t\t                ')
        # SOURCE LINE 6
        runtime._include_file(context, u'/settings.mako', _template_uri)
        context.write(u'\n                </div>\n                <div class="box" id="plot">\n                        <h1>Plot Area</h1>\n\t\t                ')
        # SOURCE LINE 10
        runtime._include_file(context, u'/plot.mako', _template_uri)
        context.write(u'\n                </div>\n        </div>\n        <div id="right">\n                <div class="box" id="datapoints">\n                        <h1>Datapoints</h1>\n                        <a class="toggle" href="javascript: toggle(\'d_facts\');">hide</a>\n\t\t                ')
        # SOURCE LINE 17
        runtime._include_file(context, u'/datapoints.mako', _template_uri)
        context.write(u'\n                </div>\n                <div class="box" id="compare">\n                        <h1>Revision Details</h1>\n                        <a class="toggle" href="javascript: toggle(\'d_compare\');">hide</a>\n\t\t                ')
        # SOURCE LINE 22
        runtime._include_file(context, u'/compare.mako', _template_uri)
        context.write(u'\n                </div>\n                <div class="box" id="details">\n                        <h1>General Details</h1>\n                        <a class="toggle" href="javascript: toggle(\'d_details\');">hide</a>\n\t\t                ')
        # SOURCE LINE 27
        runtime._include_file(context, u'/details.mako', _template_uri)
        context.write(u'\n                </div>\n        </div>\n\t\t')
        # SOURCE LINE 30
        runtime._include_file(context, u'/footer.mako', _template_uri)
        context.write(u'\n')
        return ''
    finally:
        context.caller_stack.pop_frame()


