module DrbMemoryTable
  AmbientAirTempVolts        = 0x01
  O2SensorVolts              = 0x02
  Zero_03                    = 0x03
  Zero_04                    = 0x04
  CoolantTemp                = 0x05
  RawCoolantTempVolts        = 0x06
  TpsVolts                   = 0x07
  MINTHR_LowestSessionTPS    = 0x08
  KnockVolts                 = 0x09
  BatteryVolts               = 0x0A
  MapValue                   = 0x0B
  DesiredNewAisPosition      = 0x0C
  Zero_0D                    = 0x0D
  ValueFromAdaptiveMemory    = 0x0E
  BaroPressure               = 0x0F
  EngineRpm_HB               = 0x10
  EngineRpm_HB_2             = 0x11 # TODO: I think this is a bug in the Turboator source (should be LB)
  Zero_12                    = 0x12
  ErrorCodeUpdateKeyOnCount  = 0x13
  Zero_14                    = 0x14
  CalculatedSparkAdvance     = 0x15
  Cylinder1Retard            = 0x16
  Cylinder2Retard            = 0x17
  Cylinder3Retard            = 0x18
  Cylinder4Retard            = 0x19
  BoostTarget                = 0x1A
end
