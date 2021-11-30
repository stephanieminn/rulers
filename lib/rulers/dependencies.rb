class Object
  def self.const_missing(name)
    # Using a boolean to track state of "calling_const_missing" wouldn't work for multiple threads
    # because as an instance variable of the Object class, it could get out of sync and lead to "stack level too deep"
    @looked_for ||= {}
    str_name = name.to_s
    raise "Class not found: #{name}" if @looked_for[str_name]
    @looked_for[str_name] = 1
    file = Rulers.to_underscore(str_name)
    require file
    klass = Object.const_get(name)
    return klass if klass
    raise "Class not found: #{name}"
  end
end
