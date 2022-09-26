
Dir[File.join(__dir__, 'lib/sonicpi', '*.rb')].each { |file| require file }

module SPILibrary
  include AliasMethods
  include LiveLoopMethods
  include PatternMethods
  include SampleMethods
  include TestMethods
  include GenerateMethods
  include FXNodeMethods
  include ListMethods
  include SynthMethods
  include HexadecimalPatternMethods
  include RandomMethods
  include Utils
end

SonicPi::Runtime.module_eval do
  include SPILibrary
end

Array.class_eval do
  include RandomMethods
end

SonicPi::Core::RingVector.class_eval do
  include RandomMethods
end
