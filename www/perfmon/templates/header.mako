<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>FreeBSD PerfMon Project</title>
  <meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />
  ${h.javascript_include_tag(builtins=True)}
  <link rel="stylesheet" type="text/css" href="/style.css" />
</head>
<body>
<script type='text/javascript'>
function toggle(id){
    var tmp = document.getElementById(id)
    if (tmp.style.display == 'none') {
        tmp.style.display = 'block'
    } else {
        tmp.style.display = 'none'
    }   
}
</script>
        <div id="header">
            <h1><a href="/plot">FreeBSD PerfMon Project</a></h1>
            <p><a href="/plot">Search</a> 
             &nbsp;&nbsp; | &nbsp;&nbsp;<a href="/overview">Overview</a> 
             &nbsp;&nbsp; | &nbsp;&nbsp;<a href="/alerts">Alerts</a> 
             &nbsp;&nbsp; | &nbsp;&nbsp;<a href="http://tinderbox.des.no/">Tinderbox</a> 
             &nbsp;&nbsp; | &nbsp;&nbsp;<a href="http://people.freebsd.org/~pho/stress/log/index.html">Stress Test</a> 
             &nbsp;&nbsp; | &nbsp;&nbsp;<a href="http://portsmon.freebsd.org/">Portsmon</a>
             &nbsp;&nbsp; | &nbsp;&nbsp;<a href="http://pointyhat.freebsd.org/errorlogs/">Pointyhat</a>
             &nbsp;&nbsp; | &nbsp;&nbsp;<a href="http://sources.zabbadoz.net/freebsd/lor.html">LOR</a>
             &nbsp;&nbsp; | &nbsp;&nbsp;<a href="#">About</a></p>
         </div>

