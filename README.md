# fluent-plugin-werkzeug-profiler [![Build Status](https://travis-ci.org/zoncoen/fluent-plugin-werkzeug-profiler.png?branch=master)](https://travis-ci.org/zoncoen/fluent-plugin-werkzeug-profiler)

## Component

### WerkzeugProfilerInput

Fluent input plugin for Werkzeug WSGI application profiler statistics.

For example, Werkzeug profiler output following log.
```
----------------------------------------
PATH: '/'
         15724 function calls (14741 primitive calls) in 0.418 seconds

   Ordered by: internal time, call count
   List reduced from 490 to 30 due to restriction <30>

   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
        2    0.226    0.113    0.226    0.113 {method 'query' of '_mysql.connection' objects}
        1    0.000    0.000    0.026    0.026 build/bdist.linux-x86_64/egg/MySQLdb/__init__.py:78(Connect)
    99/31    0.000    0.000    0.000    0.000 /usr/lib/python2.7/sre_parse.py:141(getwidth)

----------------------------------------
```
Results are as follows.
```
{ "uri"=>"/", "tot_ncalls"=>"2", "prim_ncalls"=>"2", "tottime"=>"0.226", 
  "tot_percall"=>"0.113", "cumtime"=>"0.226", "cum_percall"=>"0.113", 
  "filename:lineno(function)"=>"{method 'query' of '_mysql.connection' objects}" }, 
{ "uri"=>"/", "tot_ncalls"=>"1", "prim_ncalls"=>"1", "tottime"=>"0.000", 
  "tot_percall"=>"0.000", "cumtime"=>"0.026", "cum_percall"=>"0.026", 
  "filename:lineno(function)"=>"build/bdist.linux- x86_64/egg/MySQLdb/__init__.py:78(Connect)" }, 
{ "uri"=>"/", "tot_ncalls"=>"99", "prim_ncalls"=>"31", "tottime"=>"0.000", 
"tot_percall"=>"0.000", "cumtime"=>"0.000", "cum_percall"=>"0.000", 
    ["filename:lineno(function)"=>"/usr/lib/python2.7/sre_parse.py:141(getwidth)" }
```

## Installation

```
$ gem install fluent-plugin-werkzeug-profiler
```

## Configuration

### WerkzeugProfilerInput

```
<source>
  type werkzeug_profiler
  path path/to/werkzeug.log
  tag werkzeug.webserver
</source>
```

## License

This software is released under the MIT License, see LICENSE.txt.
