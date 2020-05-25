# SqlOptimizer

SqlOptimizer this is a gem for query optimization in your app. You can use two our method to check you query: `anayle` and `check_n_plus_one`. This is not so much, but we'll add more in the future. Also you can visit [localhost:3000/sql_optimizer](http://localhost:3000/sql_optimizer) to see information about queries in your app.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sql_optimizer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sql_optimizer
    
Run `rails g sql_optimizer` to load all files and migrations

## Usage

Visit [localhost:3000/sql_optimizer](http://localhost:3000/sql_optimizer) to see information about queries

### Analyze

Add to your query `analyze` method to see full information about queries
For example:
```
MyModel.scope.analyze
```

### Check n+1

Add to your query `check_n_plus_one` method to see if query has n+1 and if has, you'll get recommendation how to omit this.
For example:
```
MyModel.scope.check_n_plus_one
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sql_optimizer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SqlOptimizer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/sql_optimizer/blob/master/CODE_OF_CONDUCT.md).
