DrbFunction = Struct.new(
    :name,
    :cmd,
    :num_args)

module DrbFunctions
  def self.define_function(name, cmd, num_args)
    f = DrbFunction.new(name, cmd, num_args)
    const_set(name, f)
  end

  define_function(:OutputErrorCodes           , 0x10, 0) # => code1, code2, ..., 0xfe
  define_function(:OutputErrorBits            , 0x11, 0) # => HB, LB
  define_function(:SetupHiSpeedDataTransfer   , 0x12, 0) # => nothing
  define_function(:SetupATM                   , 0x13, 1) # => depends on function?
  define_function(:SendDiagnosticDataToSCI    , 0x14, 1) # => 1 byte
  define_function(:Send16BitMemoryLocation    , 0x15, 2) # => 1 byte
  define_function(:SendECUIDToSCI             , 0x16, 1) # => ?
  define_function(:ClearErrorCodes            , 0x17, 0) # => 0xe0, 0xe0, 0xe0
  define_function(:ControlASDRelay            , 0x18, 1) # => nothing?
  define_function(:SetMinIdleSpeed            , 0x19, 1) # => nothing?
  define_function(:SwitchTest                 , 0x1A, 1) # => ?
  define_function(:InitByteModeDownload       , 0x1B, 0) # => nothing
  define_function(:ResetEMR                   , 0x1C, 2) # => 0xe2 or 0x00
end

