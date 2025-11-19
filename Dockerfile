FROM ubuntu:22.04

USER root

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN apt update && apt install -y \
    curl gnupg wget unzip openjdk-17-jdk \
    git zip

RUN apt-get remove -y nodejs npm || true
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@10

RUN npm install -g @bubblewrap/cli

ENV ANDROID_HOME=/opt/android-sdk

RUN mkdir -p $ANDROID_HOME/cmdline-tools/latest

RUN cd /tmp && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -O tools.zip && \
    unzip tools.zip && \
    rm tools.zip && \
    mv cmdline-tools/* $ANDROID_HOME/cmdline-tools/latest/

RUN mkdir -p $ANDROID_HOME/licenses && \
    yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses

RUN $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0"

ENV PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0:$PATH"

ENTRYPOINT ["/entrypoint.sh"]
