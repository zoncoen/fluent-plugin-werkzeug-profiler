module Fluent

  class WerkzeugProfilerInput < TailInput
    Plugin.register_input('werkzeug_profiler', self)

    # get time format from config
    config_param :time_format, :string, :default => '%d/%b/%Y:%H:%M:%S %z'

    # override
    def configure_parser(conf)
      @parser = WerkzeugProfilerParser.new(@time_format)
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
      def initialize(time_format)
        @time_format = time_format
        @keys = ['uri', 'tot_ncalls', 'prim_ncalls', 'tottime', 'tot_percall', 'cumtime', 'cum_percall', 'filename:lineno(function)']
        @record_size = @keys.length - 2
        @path = 'path'
        @time = 'time'
      end

      def parse(values)
        time = values.shift
        array = [@keys,values].transpose.flatten
        record = Hash[*array]
        return time, record
      end

      def divide(lines)
        records = []
        # remove empty lines
        lines = lines.join('').gsub(/\n\n/, "\n").split("\n")

        for line in lines do
          if line.start_with?('-')
            @path = nil
            next
          end

          if line.start_with?('PATH:')
            path = line.split(nil)[1]
            @path = path[1..path.length-2]
            @time = Time.now.strftime(@time_format)
            next
          end

          if line.strip.split(nil)[1] == 'function' || line.strip.start_with?('ncalls', 'Ordered', 'List')
            next
          elsif @path != nil
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
        records
      end
    end
  end

end
