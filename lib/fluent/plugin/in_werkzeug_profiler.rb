module Fluent

  class WerkzeugProfilerInput < TailInput
    Plugin.register_input('werkzeug_profiler', self)

    # override
    def configure_parser(conf)
      @parser = WerkzeugProfilerParser.new
    end

    # override
    def receive_lines(lines)
      es = MultiEventStream.new

      for line in @parser.divide(lines) do
        begin
          time, record = parse_line(line)
          if time && record
            es.add(time, record)
          end
        rescue
          $log.warn line.dump, :error=>$!.to_s
          $log.debug_backtrace
        end
      end

      unless es.empty?
        Engine.emit_stream(@tag, es)
      end
    end

    class WerkzeugProfilerParser
      def initialize()
        @keys = ['uri', 'tot_ncalls', 'prim_ncalls', 'tottime', 'tot_percall', 'cumtime', 'cum_percall', 'filename:lineno(function)']
        @record_size = @keys.length - 2
        @path = nil
        @time = nil
      end

      def parse(values)
        time = values.shift
        array = [@keys,values].transpose.flatten
        record = Hash[*array]
        return time, record
      end

      def divide(lines)
        records = []

        for line in lines do
          # remove empty lines
          if line == "\n"
            next
          end

          if line.start_with?('-')
            @path = nil
            @time = nil
            next
          end

          if line.start_with?('PATH:')
            path = line.split(nil)[1]
            @path = path[1..path.length-2]
            @time = Time.now.to_i
            next
          end


          if @path == nil || @time == nil
            next
          elsif line.split(nil)[1] == 'function' || line.strip.start_with?('ncalls', 'Ordered', 'List')
            next
          else
            values = line.split(nil)
            # divide ncalls
            ncalls = values[0].split('/')
            values[0] = ncalls[0]
            values[1,0] = ncalls[ncalls.length-1]
            if values.length > @record_size + 1
              values[@record_size] = values[@record_size..values.length-1].join(' ')
            end
            record = values[0..@record_size]
            record.unshift(@path)
            record.unshift(@time)
            records << record
            next
          end
        end

        # return records as array
        return records
      end
    end
  end

end
