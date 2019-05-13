FROM oracle/graalvm-ce:19.0.0 AS native-image
COPY . /app
WORKDIR /app
RUN ./gradlew jar

RUN gu install native-image
RUN native-image -H:Name=fernflower -H:+ReportExceptionStackTraces --static -jar build/libs/fernflower.jar

FROM scratch
COPY --from=native-image /app/fernflower /fernflower
ENTRYPOINT ["/fernflower"]
