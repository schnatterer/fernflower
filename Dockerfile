FROM oracle/graalvm-ce:19.0.0 AS native-image
COPY . /app
WORKDIR /app
RUN ./gradlew jar

RUN gu install native-image

# Building without --static results in error, though.
#Warning: Aborting stand-alone image build due to reflection use without configuration.
# com.oracle.svm.hosted.FallbackFeature$FallbackImageRequest: Reflection method java.lang.Class.getMethods invoked at org.jetbrains.java.decompiler.modules.decompiler.ClasspathHelper.findMethodOnClasspath(ClasspathHelper.java:36)
RUN native-image -H:Name=fernflower -H:+ReportExceptionStackTraces --static -jar build/libs/fernflower.jar

FROM scratch
COPY --from=native-image /app/fernflower /fernflower
ENTRYPOINT ["/fernflower"]

ARG VCS_REF
ARG SOURCE_REPOSITORY_URL
ARG GIT_TAG
ARG BUILD_DATE
# See https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.authors="schnatterer" \
      org.opencontainers.image.url="https://hub.docker.com/r/schnatterer/fernflower/" \
      org.opencontainers.image.documentation="https://hub.docker.com/r/schnatterer/fernflower/" \
      org.opencontainers.image.source="${SOURCE_REPOSITORY_URL}" \
      org.opencontainers.image.version="${GIT_TAG}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.vendor="schnatterer" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.title="fernflower" \
      org.opencontainers.image.description="Fernflower is the first actually working analytical decompiler for Java and probably for a high-level programming language in general."
