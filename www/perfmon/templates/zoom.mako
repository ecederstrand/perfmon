<% import string
tag = '<img src="/plot/png/'+str(c.random)+'" ismap="ismap" usemap="#points" width="700" height="500" alt="Plot">'
js = h.update_element_function("pngplot", content=tag)
#update_element_function unecessarily escapes double quotes. Blech.
js = js.replace('\\"', '') 
%>
${js}
${h.update_element_function("points", content=str(c.map))}
