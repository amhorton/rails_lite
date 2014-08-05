require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    def initialize(req, route_params = {})

      if req.query_string
        query_string_params = parse_www_encoded_form(req.query_string)
      else
        query_string_params = []
      end

      if req.body
        body_params = parse_www_encoded_form(req.body)
      else
        body_params = {}
      end

      arr = [query_string_params, body_params, route_params]

      @params = {}

      arr.each do |param_set|

        param_set.each do |k, v|
          @params[k] = v
        end
      end

    end

    def [](key)
      @params[key]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      arrays = URI.decode_www_form(www_encoded_form)
      hash = {}

      arrays.each do |array|

        if array.first.include?("[")
          parsed = parse_key(array.first)

          parent = parsed.first
          hash[parsed.shift] = nil

          parsed.each do |el|
            assigned_hash = {el => nil}
            deep_assign(hash, parent, assigned_hash)

            parent = el
          end

          deep_assign(hash, parsed.last, array.last)
        else
          hash[array.first] = array.last
        end
      end
      hash
    end

    def deep_assign(top_hash, parent_key, new_value)
      top_hash.each do |key, value|
        if key == parent_key
          top_hash[key] = new_value
          return
        elsif value.is_a?(Hash)
          deep_assign(value, parent_key, new_value)
        end
      end
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      if key.include?("[")
        key.split(/\]\[|\[|\]/)
      else
        [key]
      end
    end
  end
end
