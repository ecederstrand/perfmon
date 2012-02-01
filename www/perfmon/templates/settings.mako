    <%
    f = h.form_remote_tag(url=h.url_for(controller='plot', action='update'), failure=h.update_element_function("pngplot", content="Error when requesting an update!"), success=h.evaluate_remote_response())
    f = f.replace("POST", "post")   # XHTML needs lowercate POST
    %>
    <div id="d_control">
    ${f}
    <p>
    OS conf: ${h.select('osconf', c.osconf_opt)}
    Branch: ${h.select('osbranch', c.osbranch_opt)}
    Start: ${h.select('osdatefirst', c.osdatefirst_opt)}
    End: ${h.select('osdatelast', c.osdatelast_opt)}<br />
    Machine: ${h.select('machine', c.machine_opt)}
    Machine conf: ${h.select('machineconf', c.machineconf_opt)}<br />
    Benchmark conf: ${h.select('benchconf', c.benchconf_opt)}
    Benchmark: ${h.select('bench', c.bench_opt)}<br />
    Scatter: ${h.radio_button('style', 'scatter', checked=True)} Line: ${h.radio_button('style', 'smooth')}
    Error bars: ${h.check_box('errorbars', value=True, checked=True)}
    ${h.submit('Apply')}
    </p>
    ${h.end_form()}
    </div>
