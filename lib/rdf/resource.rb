module RDF
  class Resource < URIRef
    include Enumerable

    attr_reader :data
    attr_writer :ns

    def self.new(*args, &block) #:nodoc:
      # We need this in order to undo the URI interning mechanism in URIRef
      resource = allocate
      resource.send(:initialize, *args, &block)
      resource
    end

    def initialize(uri = nil, ns = :dc, options = {}, &block)
      @uri = (uri.respond_to?(:to_uri) ? uri.to_uri : uri).to_s
      @data = {}
      @ns = Namespace[ns.to_sym] rescue Namespace.new(ns.to_s)
      self.rdf_type = options[:type] if options[:type]
      block.call(self) if block_given?
    end

    def ==(other)
      anonymous? ? self.equal?(other) : uri == other.uri
    end

    def each(&block)
      data.each(&block)
    end

    def anonymous?
      @uri.nil?
    end

    def with_namespace(ns, &block)
      prev_ns = @ns
      @ns = Namespace[ns.to_sym] rescue Namespace.new(ns.to_s)
      block.call(self)
      @ns = prev_ns
    end

    def namespaces
      Namespace.prefixes # FIXME
    end

    def rdf_type=(value)
      data[RDF::Namespaces::RDF[:type].uri] = value
    end

    def [](*args)
      raise ArgumentError.new('wrong number of arguments') unless (1..2).include?(args.length)

      if args.length == 1  # r[:suffix]
        name = args.shift
        uri = name.respond_to?(:to_uri) ? name.to_uri : @ns[name.to_s.gsub('_', '-')].uri
      else                 # r[:ns, :suffix]
        ns, name = args
        uri = Namespace[ns][name.to_s.gsub('_', '-')].uri
      end
      data[uri]
    end

    def []=(*args)
      raise ArgumentError.new('wrong number of arguments') unless (2..3).include?(args.length)

      if args.length == 2  # r[:suffix] = value
        name, value = args
        uri = name.respond_to?(:to_uri) ? name.to_uri : @ns[name.to_s.gsub('_', '-')].uri
      else                 # r[:ns, :suffix] = value
        ns, name, value = args
        uri = Namespace[ns][name.to_s.gsub('_', '-')].uri
      end
      data[uri] = value
    end

    #def method_missing(method, *args, &block)
    #  #suffix = method.to_s.gsub(/[=\?]+$/, '').gsub('_', '-').to_sym
    #  self[method.to_s.gsub('_', '-')]
    #end

  end
end