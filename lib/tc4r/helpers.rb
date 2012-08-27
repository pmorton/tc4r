module Tc4r
  module Helpers
    def self.symbolize(obj)
      return obj.inject({}){|memo,(k,v)| memo[k.to_sym] =  symbolize(v); memo} if obj.is_a? Hash
      return obj.inject([]){|memo,v    | memo           << symbolize(v); memo} if obj.is_a? Array
      return obj
    end

    def self.underscore(obj)
      obj.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
    end

    def self.sym_score(obj)
      return obj.inject({}){|memo,(k,v)| memo[k.underscore.to_sym] =  symbolize(v); memo} if obj.is_a? Hash
      return obj
    end

  end
end