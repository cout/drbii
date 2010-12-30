require 'drbii/protocol/realtime_data_sub_functions'
require 'drbii/protocol/drb_memory_tabled'

module DrbDiagnosticsDataSubFunctions
  include DrbMemoryTable            # 0x01 - 0x1A
  include RealtimeDataSubFunctions  # 0x40 - 0x42
  # any other value will return 0x00
end
