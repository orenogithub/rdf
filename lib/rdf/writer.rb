module RDF
  class Writer

    @@subclasses = []
    @@file_extensions = {}
    @@content_types = {}
    @@content_encoding = {}

    def self.each(&block)
      !block_given? ? @@subclasses : @@subclasses.each { |klass| yield klass }
    end

    def self.content_types
      @@content_types
    end

    def self.file_extensions
      @@file_extensions
    end

    def self.for(format)
      require "rdf/writers/#{format}"

      klass = case format.to_sym
        when :ntriples  then RDF::Writers::NTriples
        when :turtle    then RDF::Writers::Turtle
        when :notation3 then RDF::Writers::Notation3
        when :rdfxml    then RDF::Writers::RDFXML
        when :trix      then RDF::Writers::TriX
      end
    end

    def self.open(*args, &block)
      require 'stringio'

      StringIO.open do |buffer|
        self.new(buffer, *args) { |writer| block.call(writer) }
        buffer.string
      end
    end

    def initialize(stream = $stdout, options = {}, &block)
      @stream, @options = stream, options
      @nodes, @node_id = {}, 0

      if block_given?
        write_prologue
        block.call(self)
        write_epilogue
      end
    end

    def write_prologue; end

    def write_epilogue; end

    def <<(data)
      case data
        when Resource
          #register!(resource) && write_node(resource)
          write_resource(data)
        when Statement
          write_statement(data)
        else
          if data.respond_to?(:to_a)
            write_triple(*data.to_a)
          else
            raise ArgumentError.new("expected RDF::Statement or RDF::Resource, got #{data.inspect}")
          end
      end
    end

    def write_resource(subject)
      edge_nodes = []
      subject.each do |predicate, objects|
        [objects].flatten.each do |object|
          edge_nodes << object if register!(object)
          write_triple subject, predicate, object
        end
      end
      edge_nodes.each { |node| write_resource node }
    end

    def write_statements(*statements)
      statements.flatten.each { |stmt| write_statement(stmt) }
    end

    def write_statement(statement)
      write_triple statement.subject, statement.predicate, statement.object
    end

    def write_triples(*triples)
      triples.each { |triple| write_triple(*triple) }
    end

    def write_triple(subject, predicate, object)
      raise NotImplementedError.new
    end

    protected

      def self.inherited(child) #:nodoc:
        @@subclasses << child
        super
      end

      def self.content_type(type, options = {})
        @@content_types[type] ||= []
        @@content_types[type] << self

        if options[:extension]
          extensions = [options[:extension]].flatten.map { |ext| ext.to_sym }
          extensions.each { |ext| @@file_extensions[ext] = type }
        end
      end

      def self.content_encoding(encoding)
        @@content_encoding[self] = encoding.to_sym
      end

      def puts(*args)
        @stream.puts(*args)
      end

      def uri_for(uriref)
        if uriref.respond_to?(:to_uri)
          uriref.anonymous? ? @nodes[uriref] : uriref.to_uri.to_s
        else
          uriref.to_s
        end
      end

      def node_id
        "_:n#{@node_id += 1}"
      end

      def register!(resource)
        if resource.kind_of?(RDF::Resource)
          unless @nodes[resource] # have we already seen it?
            @nodes[resource] = resource.uri || node_id
          end
        end
      end

      def escaped(string)
        string.gsub("\\", "\\\\").gsub("\t", "\\\t").
          gsub("\n", "\\\n").gsub("\r", "\\\r").gsub("\"", "\\\"")
      end

      def quoted(string)
        "\"#{string}\""
      end

  end

  module Writers; end
end