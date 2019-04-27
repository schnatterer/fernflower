FROM debian:stretch-20190326-slim AS build-env

#FROM gradle:4.0-jdk8 as gradle
#COPY --chown=gradle:gradle . /home/gradle/src
#WORKDIR /home/gradle/src
#RUN gradle jar

FROM oracle/graalvm-ce:1.0.0-rc16 AS native-image
#COPY --from=gradle /home/gradle/src /app/
COPY . /app
WORKDIR /app
RUN ./gradlew jar


#Warning: Abort stand-alone image build. Class initialization failed: org.jetbrains.java.decompiler.main.ClassReference14Processor
 #Detailed message:
RUN native-image --static -H:Name=fernflower -H:+ReportExceptionStackTraces -jar build/libs/fernflower.jar

# Only way to make distroless build deterministic: Use repo digest
# openjdk version "1.8.0_212"
#FROM gcr.io/distroless/java@sha256:84a63da5da6aba0f021213872de21a4f9829e4bd2801aef051cf40b6f8952e68
FROM openjdk:8u212-slim-stretch
#FROM gcr.io/distroless/base
COPY --from=native-image /app/fernflower /fernflower
COPY --from=native-image /app/build/libs/fernflower.jar /fernflower.jar
RUN ls -l
COPY --from=build-env /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/libz.so.1
ENTRYPOINT ["/fernflower"]
#Error: Could not find or load main class org.jetbrains.java.decompiler.main.decompiler.ConsoleDecompiler
