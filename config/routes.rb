Rails.application.routes.draw do
  get 'sql_optimizer', to: 'sql_optimizer/sql_optimizer#index'
  get 'graph',         to: 'sql_optimizer/sql_optimizer#graph'
end
