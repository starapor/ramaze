#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Ramaze

  # This module provides a basic skeleton for your own loggers to be compatible.
  # The minimal usage is like this:
  #
  #   class MyLogger
  #     include Informing
  #
  #     def inform(tag, *args)
  #       p tag => args
  #     end
  #   end

  module Informing
    def tag_inform(tag, meth, *strings)
      strings.each do |string|
        string = (string.respond_to?(:to_str) ? string : string.send(meth))
        inform(tag, string)
      end
    end

    # Converts everything given to strings and passes them on with :info

    def info(*objects)
      tag_inform(:info, :to_s, *objects)
    end

    # Converts everything given to strings and passes them on with :warn

    def warn(*objects)
      tag_inform(:warn, :to_s, *objects)
    end

    # inspects objects if they are no strings. Tag is :debug

    def debug(*objects)
      tag_inform(:debug, :inspect, *objects)
    end

    alias << debug

    # Takes either an Exception or just a String, formats backtraces to be a bit
    # more readable and passes all of this on to tag_inform :error

    def error(ex)
      if ex.respond_to?(:exception)
        message = ex.backtrace[0..Global.backtrace_size]
        message.map{|m| m.gsub!(/^#{Dir.pwd}/, '.') }
        message.unshift(ex.inspect)
      else
        message = ex.to_s
      end
      tag_inform(:error, :to_s, *message)
    end

    # raises

    def inform(*args)
      raise "#inform should be implemented by an instance including this module (#{self})"
    end

    # nothing

    def shutdown
    end

    # stub for WEBrick

    def debug?
      false
    end
  end
end
