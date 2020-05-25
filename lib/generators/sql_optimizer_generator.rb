class SqlOptimizerGenerator < Rails::Generators::Base

  desc 'This generator creates an migration file, model file, sql_optimizer file and append to routes lines'
  def migrate_query_logs
    migration_number = Dir.glob("#{Rails.root}/db/migrate/*").max_by { |name| name[/\d+/].to_i }[/\d+/].to_i + 1
    create_file "db/migrate/#{migration_number}_create_query_logs.rb", migration_content
    create_file 'app/models/query_log.rb', model_content
    create_file 'app/controllers/sql_optimizer.rb', controller_content
    application(nil, env: :development) { initializer_content }
    route route_content
    rake 'db:migrate'
    puts 'Done'
  end

  def migration_content
    <<~RUBY
      class CreateQueryLogs < ActiveRecord::Migration[6.0]
        def change
          create_table :query_logs do |t|
            t.string :query
            t.float :duration
            t.string :source
            t.bigint :follow_id
            t.integer :n_plus_one_size, default: 1

            t.timestamps
          end
        end
      end
    RUBY
  end

  def model_content
    <<~RUBY
      class QueryLog < ApplicationRecord
      end
    RUBY
  end

  def route_content
    <<~RUBY
      if Rails.env.development?
        get 'sql_optimizer', to: 'sql_optimizer#index'
        get 'graph',         to: 'sql_optimizer#graph'
      end

    RUBY
  end

  def initializer_content
    <<~RUBY
      # This is for tracking sql queries
      QueryTrace.enable!

    RUBY
  end

  def controller_content
    <<~RUBY
      class SqlOptimizerController < ApplicationController

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
    RUBY
  end

end
