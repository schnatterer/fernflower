FROM debian:stretch-20190326-slim AS build-env

#FROM gradle:4.0-jdk8 as gradle
#COPY --chown=gradle:gradle . /home/gradle/src
#WORKDIR /home/gradle/src
#RUN gradle jar

FROM oracle/graalvm-ce:1.0.0-rc14 AS native-image
#COPY --from=gradle /home/gradle/src /app/
COPY . /app
WORKDIR /app
RUN ./gradlew jar
RUN native-image --static -H:Name=fernflower -H:+ReportExceptionStackTraces -jar build/libs/fernflower.jar

FROM gcr.io/distroless/base
COPY --from=native-image /app/fernflower /fernflower
COPY --from=build-env /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/libz.so.1
CMD ["/fernflower"]