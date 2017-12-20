// https://logback.qos.ch/manual/layouts.html
// Example: Sample usage of a PatternLayout (logback-examples/src/main/java/chapters/layouts/PatternSample.java)
// https://github.com/qos-ch/logback/blob/master/logback-examples/src/main/java/chapters/layouts/PatternSample.java
package chapters.layouts;

import org.slf4j.LoggerFactory;

import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.classic.encoder.PatternLayoutEncoder;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.ConsoleAppender;

public class PatternSample {

  static public void main(String[] args) throws Exception {
    Logger rootLogger = (Logger)LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME);
    LoggerContext loggerContext = rootLogger.getLoggerContext();
    // we are not interested in auto-configuration
    loggerContext.reset();

    PatternLayoutEncoder encoder = new PatternLayoutEncoder();
    encoder.setContext(loggerContext);
    encoder.setPattern("%-5level [%thread]: %message%n");
    encoder.start();

    ConsoleAppender<ILoggingEvent> appender = new ConsoleAppender<ILoggingEvent>();
    appender.setContext(loggerContext);
    appender.setEncoder(encoder); 
    appender.start();

    rootLogger.addAppender(appender);

    rootLogger.debug("Message 1"); 
    rootLogger.warn("Message 2");
  } 
}
// In the above example, the conversion pattern is set to be "%-5level [%thread]: %message%n". A synopsis of conversion word included in logback will be given shortly. Running PatternSample application as:

// java java chapters.layouts.PatternSample

// will yield the following	output on the console.

// DEBUG [main]: Message 1 
// WARN  [main]: Message 2