#
#   COMPILE-TIME CONFIGURATIONS
#   ===========================
#   Config overrides for all environments other than development and
#   test.
#

import Config

#
#   LOGGER
#

config :logger, level: :warning
config :logger, compile_time_purge_matching: [[level_lower_than: :warning]]
