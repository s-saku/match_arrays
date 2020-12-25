require "match_arrays/version"
require "active_record"

module MatchArrays
  class Error < StandardError; end

  # A function that matches two arrays (masters, transactions) containing hash or ActiveRecord with the specified key.
  # It judges "matching", "master only", or "transaction only", and then calls the callback Proc specified for each.
  #
  # * In this gem, the elements of the masters and transactions arrays are called "MA" and "TR" respectively.
  # * Callbacks are accepted only for Proc, not for lambda, because lambda does not fit the strict error checking of block arguments.
  # * Masters and transactions are replaced with an empty array only when nil is input.
  #   This is because it is expected to work as intended in many cases.
  def self.match(masters:, transactions:, p_m_key:, p_t_key:, p_match:, p_tr_only:, p_ma_only:, attr_obj: nil)
    nil_to_array_masters = masters.nil? ? [] : masters
    nil_to_array_transactions = transactions.nil? ? [] : transactions
    raise ArgumentError, "Only an Array is accepted as the :masters argument." unless nil_to_array_masters.is_a?(Array) || nil_to_array_masters.is_a?(ActiveRecord::Associations::CollectionProxy)
    raise ArgumentError, "Only an Array is accepted as the :transactions argument." unless nil_to_array_transactions.is_a?(Array) || nil_to_array_transactions.is_a?(ActiveRecord::Associations::CollectionProxy)
    raise ArgumentError, "Only an Proc is accepted as the :p_m_key argument." unless p_m_key.is_a?(Proc)
    raise ArgumentError, "Only an Proc is accepted as the :p_t_key argument." unless p_t_key.is_a?(Proc)
    raise ArgumentError, "Only an Proc is accepted as the :p_match argument." unless p_match.is_a?(Proc)
    raise ArgumentError, "Only an Proc is accepted as the :p_tr_only argument." unless p_tr_only.is_a?(Proc)
    raise ArgumentError, "Only an Proc is accepted as the :p_ma_only argument." unless p_ma_only.is_a?(Proc)

    # Generate a hash that can access MA with the key defined in p_m_key
    ma_hash = nil_to_array_masters.each_with_object({}) do |ma, hash|
      key = p_m_key.call(ma).to_s # Force to_s to avoid matching type errors
      hash[key] = ma
    end

    # Create a hash with the same content as ma_hash.
    # Deleting a MA that matches a TR from this hash, and determine that the remaining elements are "MA only"
    ma_only_hash = nil_to_array_masters.each_with_object({}) do |ma, hash|
      key = p_m_key.call(ma).to_s # Force to_s to avoid matching type errors
      hash[key] = ma
    end

    # Create a hash that can access TR with the key defined in p_t_key
    tr_hash = nil_to_array_transactions.each_with_object({}) do |tr, hash|
      key = p_t_key.call(tr).to_s # Force to_s to avoid matching type errors
      hash[key] = tr
    end

    # Read TRs one at a time and determine whether it is "matching" or "TR only"
    tr_hash.each do |key, tr|
      if ma_hash[key].present?
        p_match.call(ma_hash[key], tr, attr_obj, nil_to_array_masters, nil_to_array_transactions)
        ma_only_hash.delete(key)
      else
        p_tr_only.call(tr, attr_obj, nil_to_array_masters, nil_to_array_transactions)
      end
    end

    # Call the "MA only" callback.
    ma_only_hash.each_value do |ma|
      p_ma_only.call(ma, attr_obj, nil_to_array_masters, nil_to_array_transactions)
    end
  end
end
