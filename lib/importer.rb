class Importer
  def self.import(publisher, path, delimiter = ' ')
    self.new.import(publisher, path, delimiter)
  end

  def import(publisher, path, delimiter)
    data = []
    File.open(path, 'r') do |file|
      parser = get_fields(file, delimiter)

      file.each_line do |line|
        data << parser.parse(line)
      end
    end

    build_objects(publisher, data)
  end

  def get_fields(file, delimiter)
    header_map = {
      'merchant' => :advertiser,
      'date' => :start_date,
      'ends' => :end_date,
      'deal' => :description,
      'price' => :price,
      'value' => :value,
    }

    line = file.readline.downcase.sub(/#{delimiter}+\n$/, '')
    fields = line.split(/#{delimiter}+/).map{|f| header_map[f]}
    validate_header(fields, delimiter)
    Parser.new(fields, delimiter)
  end

  def validate_header(fields, delimiter)
    fields.length != fields.uniq.length and raise "Header fields not recognized as unique"
    return unless delimiter == ' '

    text_fields = [:advertiser, :description]

    fields.each_with_index do |f, i|
      next if i == 0
      ([f, fields[i-1]] - text_fields).empty? and raise "Cannot separate adjacent text fields with a single space"
    end

    missing = [:advertiser, :start_date, :description, :price, :value] - fields
    missing.empty? or raise "Required field(s) #{missing * ' '} missing"
  end

  def build_objects(publisher, data)
    ActiveRecord::Base.transaction do
      data.each do |spec|
        puts spec.inspect
        advertiser = publisher.advertisers.find_or_create_by_name(spec.delete(:advertiser))
        puts advertiser.inspect
        deal = advertiser.deals.create(spec)
      end
    end
  end

  class Parser
    def parser
      return @parser if @parser
      raw = {
        advertiser: [:string, true],
        start_date: [:date, true, :start_at],
        end_date: [:date, false, :end_at],
        description: [:string, true],
        price: [:int, true],
        value: [:int, true],
      }
      raw.each{|k, v| v << k if v.length == 2}
      @parser = raw
    end

    def initialize(fields, delimiter)
      @delimiter = delimiter
      partials = fields.map do |field|
        klass, required, attribute = parser[field]
        send("#{klass}_scanner", required)
      end
      @regexp = /^#{partials * "#{delimiter}+"}$/
      @fields = fields
    end

    def parse(line)
      match = @regexp.match(line) or raise "Could not parse line #{line}"
      data = match[1..(@fields.length)]
      @fields.zip(data).inject({}) do |results, info|
        field, datum = info
        results[parser[field].last] = datum ? send("#{field}_converter", datum) : nil
        results
      end
    end

    def string_scanner(required)
      /([a-zA-Z].*?)#{required ? '' : '?'}(?:(?=#{@delimiter}+\d)|$)/
    end

    def int_scanner(required)
      /(\d+)#{required ? '' : '?'}/
    end

    def date_scanner(required)
      /(\d+\/\d+\/\d+)#{required ? '' : '?'}/
    end

    def advertiser_converter(data)
      data.sub(/#{@delimiter}+$/, '')
    end

    alias_method :description_converter, :advertiser_converter

    def price_converter(data)
      data.to_i
    end

    alias_method :value_converter, :price_converter

    def start_date_converter(data)
      "#{data} 00:00:00".to_datetime
    end

    def end_date_converter(data)
      "#{data} 23:59:59".to_datetime
    end
  end
end
