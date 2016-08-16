module RDF
  ##
  # An RDF Dataset
  #
  # Datasets are immutable by default. {RDF::Repository} provides an interface
  # for mutable Datasets.
  #
  # @todo DOCS!
  #
  # @see https://www.w3.org/TR/rdf11-concepts/#section-dataset
  # @see https://www.w3.org/TR/rdf11-datasets/
  class Dataset
    include RDF::Enumerable
    include RDF::Durable
    include RDF::Queryable

    DEFAULT_GRAPH = false

    ISOLATION_LEVELS = [ :read_uncommitted,
                         :read_committed,
                         :repeatable_read,
                         :snapshot,
                         :serializable ].freeze

    ##
    # @param [RDF::Enumerable, Array<RDF::Statement>]
    # @yield [dataset]
    # @yieldparam [RDF::Dataset]
    #
    # @todo optimize. statements.to_a.dup is definitely not the best.
    def initialize(statements: nil, **options, &block)
      @statements = statements.to_a.dup.freeze

      if block_given?
        case block.arity
          when 1 then yield self
          else instance_eval(&block)
        end
      end
    end

    ##
    # @private
    # @see RDF::Durable#durable?
    def durable?
      false
    end

    ##
    # @private
    # @see RDF::Enumerable#each_statement
    def each_statement
      if block_given?
        @statements.each { |st| yield st }
        self
      end

      enum_statement 
    end
    alias_method :each, :each_statement

    ##
    # Returns a developer-friendly representation of this object.
    #
    # @return [String]
    def inspect
      sprintf("#<%s:%#0x(%s)>", self.class.name, __id__, uri.to_s)
    end

    ##
    # Outputs a developer-friendly representation of this object to
    # `stderr`.
    #
    # @return [void]
    def inspect!
      each_statement { |statement| statement.inspect! }
      nil
    end

    ##
    # @return [Symbol] a representation of the isolation level for reads of this
    #   Dataset. One of `:read_uncommitted`, `:read_committed`, `:repeatable_read`,
    #  `:snapshot`, or `:serializable`.
    def isolation_level
      :read_committed
    end

    ##
    # @private
    # @see RDF::Enumerable#supports?
    def supports?(feature)
      return true if feature == :graph_name
      super
    end

    protected
    
    ##
    # @todo DOCS!
    def query_pattern(pattern, options = {}, &block)
      return super unless pattern.graph_name == DEFAULT_GRAPH

      if block_given?
        pattern = pattern.dup
        pattern.graph_name = nil

        each_statement do |statement|
          yield statement if (statement.graph_name == DEFAULT_GRAPH) && 
                             pattern === statement
        end
      else
        enum_for(:query_pattern, pattern, options)
      end
    end
  end
end
