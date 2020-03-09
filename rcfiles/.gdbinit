set prompt \033[32m(gdb) \033[0m
set print pretty on
set print array on
set print symbol on

#... This might have been why I have a hard time accessing the backtrace on segfaults...
#handle all nostop
handle SIGUSR1 SIGUSR2 SIGILL nostop

# Do not stop all threads when hitting a breakpoint.
# Has the potential to cause problems, depending on the program.
set pagination off
set non-stop on
# Respond to commands, even when the inferior is running.
set target-async on

# Load local .gdbinit files.
add-auto-load-safe-path /
set auto-load local-gdbinit on

# Save command history
set history save on
set history size unlimited
# Remove duplicates in the last 20 entries.
set history remove-duplicates 20

# Add STL pretty-printers
python
import sys
sys.path.insert(0, '/usr/share/gcc-8/python')
from libstdcxx.v6.printers import register_libstdcxx_printers
register_libstdcxx_printers(None)
end
