#!/bin/bash
# Simple launcher script (Unix-like)
STEPLY_HOME="$(cd "$(dirname "$0")/.." && pwd)"

# Use bundled JRE if present, otherwise fall back to system java
if [ -x "$STEPLY_HOME/jre/bin/java" ]; then
  JAVA_BIN="$STEPLY_HOME/jre/bin/java"
elif [ -n "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/java" ]; then
  JAVA_BIN="$JAVA_HOME/bin/java"
else
  JAVA_BIN="java"
fi

CLASSPATH=".:$STEPLY_HOME/lib/*:$STEPLY_HOME/lib/*-jar-with-dependencies.jar"
"$JAVA_BIN" -cp "$CLASSPATH" -Dsteply.home="$STEPLY_HOME" -Dlogback.configurationFile="$STEPLY_HOME/config/logback.xml" org.jsmart.steply.cli.SteplyCLI "$@"
