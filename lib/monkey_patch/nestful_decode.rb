module Nestful
  class Request
    attr_accessor :buffer_binmode

      def decoded(result)
        if buffer
          data  = Tempfile.new("nfr.#{rand(1000)}")
          data.binmode if buffer_binmode
          size  = 0
          total = result.content_length
          
          result.read_body do |chunk|
            callback(:progress, self, total, size += chunk.size)
            data.write(chunk)
          end
          
          data.rewind
          data
        else
          return result if raw
          data = result.body
          format ? format.decode(data) : data
        end
      end

  end
end
