DrbFunction = Struct.new(
    :cmd,
    :num_args)

module DrbFunctions
  def self.f(*x); return DrbFunction.new(*x); end
    
  OutputErrorCodes           = f(0x10, 0) # => code1, code2, ..., 0xfe
  OutputErrorBits            = f(0x11, 0) # => HB, LB
  SetupHiSpeedDataTransfer   = f(0x12, 0) # => nothing
  SetupATM                   = f(0x13, 1) # => depends on function?
  SendDiagnosticDataToSCI    = f(0x14, 1) # => 1 byte
  Send16BitMemoryLocation    = f(0x15, 2) # => 1 byte
  SendECUIDToSCI             = f(0x16, 1) # => ?
  ClearErrorCodes            = f(0x17, 0) # => 0xe0, 0xe0, 0xe0
  ControlASDRelay            = f(0x18, 1) # => nothing?
  SetMinIdleSpeed            = f(0x19, 1) # => nothing?
  SwitchTest                 = f(0x1A, 1) # => ?
  InitByteModeDownload       = f(0x1B, 0) # => nothing
  ResetEMR                   = f(0x1C, 2) # => 0xe2 or 0x00
end

