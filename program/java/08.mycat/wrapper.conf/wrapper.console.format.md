Java Service Wrapper - wrapper.console.format Property https://wrapper.tanukisoftware.com/doc/english/prop-console-format.html

Format to use for output to the console. Logging has been intentionally kept simple.

The format consists of the following tokens:

'L' for log level,
'P' for prefix,
'D' (Since ver. 3.1.0) for thread,
'T' for time,
'Z' for millisecond time,
'R' quite duration milliseconds showing the time since the previous JVM output,
'U' (Since ver. 3.5.0) for approximate uptime in seconds (based on internal tick counter and is valid up to one year from startup),
'G' (Since ver. 3.5.8) for time in milliseconds it tool to log the previous log entry (See wrapper.log.warning.threshold for more information),
'W' (Since ver. 3.5.30) for the PID of the Wrapper process.
'J' (Since ver. 3.5.30) for the PID of the Java process (if the JVM is up).
'M' for message.
If the format contains these tokens above, then it will be output with the specified formation. The order of the tokens does not affect the way the log appears, but the 'M' (for message) token should usually be placed last as it is the only column without a uniform width. If the property is missing tokens or commented out, then the default value 'PM' will be used.

Property Example:

Property Example:
wrapper.console.format=PM
Disable console output:

Setting the property to a blank value will cause console output to be disabled.

Property Example:
wrapper.console.format=
Output Example:

The following examples demonstrate the output with various settings. Note that the first two lines are output from the Wrapper, while the last is output from the JVM.

Output Example with the property "wrapper.console.format=LPZM"
STATUS | wrapper  | 2001/12/11 13:45:33.560 | --> Wrapper Started as Console
STATUS | wrapper  | 2001/12/11 13:45:33.560 | Launching a JVM...
INFO   | jvm 1    | 2001/12/11 13:45:35.575 | Initializing...
Output Example with the property "wrapper.console.format=LPTM"
STATUS | wrapper  | 2001/12/11 13:45:33 | --> Wrapper Started as Console
STATUS | wrapper  | 2001/12/11 13:45:33 | Launching a JVM...
INFO   | jvm 1    | 2001/12/11 13:45:35 | Initializing...
Output Example with the property "wrapper.console.format=PTM"
wrapper  | 2001/12/11 13:45:33 | --> Wrapper Started as Console
wrapper  | 2001/12/11 13:45:33 | Launching a JVM...
jvm 1    | 2001/12/11 13:45:35 | Initializing...
Output Example with the property "wrapper.console.format=PM"
wrapper  | --> Wrapper Started as Console
wrapper  | Launching a JVM...
jvm 1    | Initializing...
Output Example with the property "wrapper.console.format=M"
--> Wrapper Started as Console
Launching a JVM...
Initializing...
Output Example with the property "wrapper.console.format="
< No Output >
The format token 'D' for thread is mainly useful for debugging the Wrapper. It displays which internal Wrapper thread output a given log message. It does not show information about Java threads.

Output Example with the property "wrapper.console.format=LPDTM"
STATUS | wrapper  | main    | 2001/12/11 13:45:33 | --> Wrapper Started as Console
STATUS | wrapper  | main    | 2001/12/11 13:45:33 | Launching a JVM...
INFO   | jvm 1    | main    | 2001/12/11 13:45:35 | Initializing...
Reference: Console
wrapper.console.direct (3.5.21)
Specifies whether the Wrapper will use Windows APIs or pipes to write console log outputs.

wrapper.console.flush (3.2.0)
Configures the Wrapper to flush stdout after each line of output is sent to the console.

wrapper.console.format (1.0.0)
Configures the format of outputs sent to the console.

wrapper.console.loglevel (1.0.0)
Filters messages sent to the console according to their log levels.

wrapper.console.fatal_to_stderr (3.5.3)
wrapper.console.error_to_stderr (3.5.3)
wrapper.console.warn_to_stderr (3.5.3)
Controls whether warning messages sent to the console are logged through stdout or stderr.

wrapper.console.title (3.1.0)
Sets the title of the console in which the Wrapper is running.

wrapper.console.title.<platform> (3.3.0)
Set the console title per platform.

wrapper.disable_console_input (3.3.2)
Disables the Wrapper's ability to process console input in the JVM.

wrapper.ntservice.console (3.1.0)
wrapper.ntservice.generate_console (3.3.2)
wrapper.ntservice.hide_console (3.0.4)
wrapper.ntservice.interactive (3.0.0)
wrapper.javaio.buffer_size (3.5.21)
Controls the size of the buffer used by the pipe between the JVM and Wrapper processes.

wrapper.javaio.use_thread (3.5.21)
Controls whether the Wrapper uses a dedicated thread to process console output from the JVM.