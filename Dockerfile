FROM node:22
USER root

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN apt update && apt install -y \
    curl wget unzip openjdk-17-jdk git zip

RUN npm install --silent -g @bubblewrap/cli

ENV ANDROID_HOME=/opt/bubblewrap/android_sdk
ENV BUBBLEWRAP_ALLOW_CUSTOM_SDKS=true
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0:$PATH

RUN mkdir -p /opt/bubblewrap/jdk
RUN cp -r /usr/lib/jvm/java-17-openjdk-amd64/* /opt/bubblewrap/jdk/

RUN mkdir -p $ANDROID_HOME/cmdline-tools/latest
RUN cd /tmp && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -O tools.zip && \
    unzip -q tools.zip && \
    mv cmdline-tools/* $ANDROID_HOME/cmdline-tools/latest/

RUN mkdir -p $ANDROID_HOME/tools

RUN yes | sdkmanager --licenses

RUN sdkmanager \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0"

RUN mkdir -p /opt/bubblewrap && \
    echo '{"jdkPath":"/opt/bubblewrap/jdk","androidSdkPath":"'"$ANDROID_HOME"'"}' > /opt/bubblewrap/config.json && \
    chmod -R 777 /opt/bubblewrap

ENTRYPOINT ["/entrypoint.sh"]
