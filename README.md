# MatchArrays

A ruby gem that matches two arrays and executes a callback based on the match result.

This gem is especially useful in the process of DB updating with values posted via API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'match_arrays'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install match_arrays

## Usage

### Prepare two arrays (masters, transactions) with elements of Hash or Rails ActiveRecord.

```Ruby
masters = [{ k: "a", v: 1 }, { k: "b", v:2 }]
transactions = [{ k: "b", v: 3 }, { k: "c", v:4 }]
```

masters means the base array and transactions means the dependent array.
For example, in the context of updating the DB via the API, masters means the DB values and transactions means the values sent from the API.

In this gem, the element of masters is represented as MA, and the element of transactions as TR.

### Define a Proc that specifies the matching key for each array element.

```Ruby
p_m_key = proc { |ma| ma[:k] }
p_t_key = proc { |tr| tr[:k] }
```

### Define the Proc you want to call in each case: Matching, TR only, MA only.

```Ruby
p_match = proc do |ma, tr|
  # something to do when matching
  # e.g. fetch MA data from DB, and update DB by TR value.
end

p_tr_only = proc do |t|
  # something to do when TR only
  # e.g. create a new record by TR value
end

p_ma_only = proc do |m|
  # something to do when MA only
  # e.g. delete MA record
end
```

### Call the Match method to execute the specified Proc while matching two arrays.

```Ruby
MatchArrays.match(
  masters: masters,
  transactions: transactions,
  p_m_key: p_m_key,
  p_t_key: p_t_key,
  p_match: p_match,
  p_tr_only: p_tr_only,
  p_ma_only: p_ma_only
)
```

### (Optional) You can give freely available arguments.

```
tr_only_records = []

p_tr_only = proc do |t, tr_only_records|
  tr_only_records.push(t)
end

MatchArrays.match(
  (the same as above),
  attr_obj: tr_only_records )

puts tr_only_records
#=> [{ k: "c", v:4 }]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/s-saku/match_arrays.

## Change Log

### v1.0.0

First release