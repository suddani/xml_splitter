class XmlSplitter::Splitter
  attr_accessor :element, :element_count

  def magic_start
    'XXXSTART'
  end

  def magic_stop
    'STOPXXX'
  end

  def sgrep_bin
    @sgrep_bin ||= %w{ sgrep sgrep2 }.detect { |bin| `which #{bin}`; $?.success? }
  end

  def initialize(element: "entity", element_count: 1000)
    @element = element
    @element_count = element_count
  end

  def tempfile
    @tempfile ||= begin
      File.new("out.zip", "wb+")
      # f = Tempfile.new
      # f.binmode
      # f
    end
  end

  def remove_tempfile
    if @tempfile
      @tempfile.close
      # @tempfile.unlink
      puts "Closed tempfile"
    end
  end

  def stream
    @stream||=Zip::OutputStream.new("out.zip")
  end

  def close_stream
    if @stream
      @stream.close
      @stream = nil
      puts "Closed zlib stream"
    end
  end

  def save(import_entity)
    @import_entity_count ||= 0
    @import_entity_count += 1
    stream.put_next_entry "xml_entities-#{@import_entity_count}.xml"
    stream.puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<jobs>\n#{import_entity}\n</jobs>"
    puts "Write entry"
  end

  def emit(import_entity)
    @stored ||= 0
    @stored += 1
    @store ||= ""
    @store = "#{@store}#{import_entity}"
    if @stored > element_count
      save(@store)
      @stored = 0
      @store=""
    end
  end

  def element_start
    "<#{element}>"
  end

  def element_stop
    "</#{element}>"
  end

  def run(input:)
    leftover = ''
    leftover = ''
    IO.popen([ sgrep_bin, '-n', '-o', "#{magic_start}%r#{magic_stop}", %{"#{element_start}" .. "#{element_stop}"}, input ]) do |io|
      while additional = io.read(65536)
        buffer = leftover + additional
        while (start = buffer.index(magic_start)) and (stop = buffer.index(magic_stop))
          element_body = buffer[(start+magic_start.length)...stop] + '>'
          # what "emit" does is up to you
          emit element_body
          buffer = buffer[(stop+magic_stop.length)..-1]
        end
        leftover = buffer
      end
      save($store) #save the last batch if there is one

      close_stream
      return "out.zip" unless block_given?
      yield "out.zip"
      # remove_tempfile
    end
  end
end
