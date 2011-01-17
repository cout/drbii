MemoryLocationBase = Struct.new(
    :address,
    :name,
    :type,
    :units,
    :_1,
    :min,
    :max,
    :_2,
    :_3,
    :_4,
    :_5,
    :_6,
    :gauge)

class MemoryLocation < MemoryLocationBase
  def read(drbii)
    if self.type == 'Byte' then
      x = drbii.send_16bit_memory_location(self)
      return x
    elsif self.type == 'Word' then
      x1 = drbii.send_16bit_memory_location(self)
      x2 = drbii.send_16bit_memory_location(self, 1)
      return (x1 << 8 | x2)
    else
      raise "Unknown type #{self.type}"
    end
  end
end

