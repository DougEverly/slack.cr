class Animal
  property type : String

  def initialize(@type : String)
  end
end

class Dog < Animal
  property color : String

  def initialize(type : String)
    super
    @color = "brown"
  end
end

e = Dog.new("Cooper")
