module SqlOptimizer

  class SqlOptimizerController < ::ApplicationController

    layout false

    # GET /sql_optimizer
    def index
      @query_logs = QueryLog.where.not(source: nil)
      @popular_queries = @query_logs.group_by(&:query).sort_by { |_, val| val.size }.last(3)
      @max_query = @query_logs.order(duration: :desc).first
      @min_query = @query_logs.order(:duration).first
    end

    # GET /graph
    def graph
      @query_logs = QueryLog.where.not(source: nil)
      render json: collect_graph.to_json
    end

    private

    def collect_graph
      @query_logs.group_by(&:query).first(10).map.with_index do |query, i|
        durations = query[1].map(&:duration)
        avg_time  = durations.reduce(:+) / durations.size.to_f
        {
          index: i,
          avg_time: avg_time.round(2),
          data: {
            query: query[1].first.query,
            name:  query[1].first.source,
            size:  query[1].size
          }
        }
      end
    end

  end

end
