MemoryLocationBase = Struct.new(
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
end

