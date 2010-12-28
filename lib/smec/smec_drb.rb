# TODO: Generate from asm source
class DrbFunctions
  OutputErrorCodes           = 0x10
  OutputErrorBits            = 0x11
  SetupHiSpeedDataTransfer   = 0x12
  SetupATM                   = 0x13
  SendDiagnosticDataToSCI    = 0x14
  DRB_Return_15              = 0x15
  SendECUIDToSCI             = 0x16
  ClearErrorCodes            = 0x17
  DRB_Return_18              = 0x18
  DRB_Return_19              = 0x19
  SwitchTest                 = 0x1A
  InitByteModeDownload       = 0x1B
  DRB_Return_1C              = 0x1C
end

# TODO: Generate from asm source
class AtmSubFunctions
  ATM_Return_00              = 0x00
  IgnitionCoil               = 0x01
  ATM_Return_02              = 0x02
  ATM_Return_03              = 0x03
  InjBank1                   = 0x04
  InjBank2                   = 0x05
  ATM_Return_06              = 0x06
  AISMotorOpenClose          = 0x07
  FanRelay                   = 0x08
  ACClutchRelay              = 0x09
  ASDRelay                   = 0x0A
  PurgeSolenoid              = 0x0B
  SCServoSolenoid            = 0x0C
  AlternatorField            = 0x0D
  Tachometer                 = 0x0E
  PTUIndicator               = 0x0F
  EGRSolenoid                = 0x10
  WGSolenoid                 = 0x11
  BaroSolenoid               = 0x12
  ATM_Return_13              = 0x13
  AllSolenoidRelays          = 0x14
  ATM_Return_15              = 0x15
  ATM_Return_16              = 0x16
  ATM_Return_17              = 0x17
  ATM_Return_18              = 0x18
  ATM_Return_19              = 0x19
end

class SwitchTestSubFunctions
  SendSwitchStateToSerial    = 0x01
  SendOutputStatusToSerial   = 0x02
  SendOutputStatusToSerial2  = 0x03
end

class RealtimeDataSubFunctions
  SCI_MAPVolts               = 0x40
  SCI_Speed                  = 0x41
  SCI_O2Volts                = 0x42
end

