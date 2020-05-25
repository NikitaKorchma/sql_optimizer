module ActiveRecord
  module ConnectionAdapters
    module PostgreSQL
      module DatabaseStatements
        def analyze(arel, binds = [])
          sql = "EXPLAIN ANALYZE #{to_sql(arel, binds)}"
          PostgreSQL::ExplainPrettyPrinter.new.pp(exec_query(sql, 'EXPLAIN ANALYZE', binds))
        end
      end
    end
  end
end

module ActiveRecord
  class Relation
    def analyze
      exec_analyze(collecting_queries_for_explain { exec_queries })
    end

    def check_n_plus_one
      query_logs   = QueryLog.all
      query_log    = query_logs.find_by(follow_id: query_logs.ids)
      if query_log.present?
        to_include = query_log.query[/"(.*?)"/].delete('\"')
        logger.debug "Add includes(:#{to_include}) to omit n+1 query"
      else
        logger.debug "n+1 query does'n find"
      end
    end
  end
end

module ActiveRecord
  module Explain
    def exec_analyze(queries)
      str = queries.map do |sql, binds|
        msg = "EXPLAIN ANALYZE for: #{sql}".dup
        unless binds.empty?
          msg << ' '
          msg << binds.map { |attr| render_bind(attr) }.inspect
        end
        msg << "\n"
        msg << connection.analyze(sql, binds)
        msg
      end.join("\n")

      def str.inspect
        self
      end

      str
    end
  end
end

module QueryTrace
  def self.enable!
    ::ActiveRecord::LogSubscriber.send(:include, self)
  end

  def self.append_features(klass)
    super
    klass.class_eval do
      unless method_defined?(:log_info_without_trace)
        alias_method :log_info_without_trace, :sql
        alias_method :sql, :log_info_with_trace
      end
    end
  end

  def log_info_with_trace(event)
    log_info_without_trace(event)

    return if event.payload[:name].nil? ||
      event.payload[:name] == 'SCHEMA' ||
      event.payload[:name].include?('SchemaMigration') ||
      %w[BEGIN COMMIT ROLLBACK].include?(event.payload[:sql].to_s) ||
      !ActiveRecord::Base.connection.table_exists?(QueryLog.table_name) ||
      event.payload[:sql].include?('query_logs')

    logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    query_logs = QueryLog.last(2)
    if query_logs.last.present? && query_logs.last.query == event.payload[:sql]
      query_logs.last.update(follow_id:       query_logs.first.id,
                             n_plus_one_size: query_logs.last.n_plus_one_size + 1)
    else
      QueryLog.create(
        query:    event.payload[:sql],
        source:   event.payload[:name],
        duration: event.duration.round(3)
      )
    end
    ActiveRecord::Base.logger = logger
  end
end
