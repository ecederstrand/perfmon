<% import string
# ismap=True becomes ismap="True", which FF barfs on :-/
# tag = h.tag('img', src=h.url_for(controller='plot', action='png', id=c.random), ismap=True, usemap='#points', width=700, height=500)
#tag = '<img src="'+h.url_for(controller='plot', action='png', id=c.random)+'" usemap="#points" width=700 height=500>'
tag = '<img src="/plot/png/'+str(c.random)+'" ismap="ismap" usemap="#points" width="700" height="500" alt="Plot">'
js = h.update_element_function("pngplot", content=tag)
#update_element_function unecessarily escapes double quotes. Blech.
js = js.replace('\\"', '') 
%>
${js}
${h.update_element_function("points", content=str(c.map))}
${h.update_element_function("d_facts", content=str(c.d_facts))}
${h.update_element_function("d_compare", content=str(c.d_compare))}
${h.update_element_function("d_os", content=str(c.d_os))}
${h.update_element_function("d_osconf", content=str(c.d_osconf))}
${h.update_element_function("d_machine", content=str(c.d_machine))}
${h.update_element_function("d_machineconf", content=str(c.d_machineconf))}
${h.update_element_function("d_bench", content=str(c.d_bench))}
${h.update_element_function("d_benchconf", content=str(c.d_benchconf))}
