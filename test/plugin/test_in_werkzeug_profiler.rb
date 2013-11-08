require 'helper'
require 'fileutils'

class WerkzeugProfilerInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
    FileUtils.rm_rf(TMP_DIR)
    FileUtils.mkdir_p(TMP_DIR)
  end

  def teardown
    FileUtils.rm_rf(TMP_DIR)
  end

  TMP_DIR = File.dirname(__FILE__) + "/../tmp"

  CONFIG = %[
    path #{TMP_DIR}/werkzeug-profiler-test.txt
    time_format %d-%b-%Y:%H:%M:%S
    tag test
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::InputTestDriver.new(Fluent::WerkzeugProfilerInput).configure(conf)
  end

  def test_configure
    d = create_driver
    assert_equal ["#{TMP_DIR}/werkzeug-profiler-test.txt"], d.instance.paths
    assert_equal "%d-%b-%Y:%H:%M:%S", d.instance.time_format
  end

  def test_emit
    File.open("#{TMP_DIR}/werkzeug-profiler-test.txt", "w") {|f|
      f.puts "old logs."
    }

    d = create_driver

    d.run do
      sleep 1

      File.open("#{TMP_DIR}/werkzeug-profiler-test.txt", "a") {|f|
        f.puts "--------------------------------------------------------------------------------"
        f.puts "PATH: '/'"
        f.puts "         15724 function calls (14741 primitive calls) in 0.418 seconds"
        f.puts ""
        f.puts "   Ordered by: internal time, call count"
        f.puts "   List reduced from 490 to 30 due to restriction <30>"
        f.puts ""
        f.puts "   ncalls  tottime  percall  cumtime  percall filename:lineno(function)"
        f.puts "        2    0.226    0.113    0.226    0.113 {method 'query' of '_mysql.connection' objects}"
        f.puts "        1    0.000    0.000    0.026    0.026 build/bdist.linux-x86_64/egg/MySQLdb/__init__.py:78(Connect)"
        f.puts "    99/31    0.000    0.000    0.000    0.000 /usr/lib/python2.7/sre_parse.py:141(getwidth)"
        f.puts ""
        f.puts "--------------------------------------------------------------------------------"
        f.puts ""
      }
      sleep 1
    end

    emits = d.emits
    assert_equal(true, emits.length > 0)
    assert_equal({"uri"=>"/", "tot_ncalls"=>"2", "prim_ncalls"=>"2", "tottime"=>"0.226", "tot_percall"=>"0.113", "cumtime"=>"0.226", "cum_percall"=>"0.113", "filename:lineno(function)"=>"{method 'query' of '_mysql.connection' objects}"}, emits[0][2])
    assert_equal({"uri"=>"/", "tot_ncalls"=>"1", "prim_ncalls"=>"1", "tottime"=>"0.000", "tot_percall"=>"0.000", "cumtime"=>"0.026", "cum_percall"=>"0.026", "filename:lineno(function)"=>"build/bdist.linux-x86_64/egg/MySQLdb/__init__.py:78(Connect)"}, emits[1][2])
    assert_equal({"uri"=>"/", "tot_ncalls"=>"99", "prim_ncalls"=>"31", "tottime"=>"0.000", "tot_percall"=>"0.000", "cumtime"=>"0.000", "cum_percall"=>"0.000", "filename:lineno(function)"=>"/usr/lib/python2.7/sre_parse.py:141(getwidth)"}, emits[2][2])
  end
end
