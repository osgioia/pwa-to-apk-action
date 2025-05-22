FROM ubuntu:22.04

USER root

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Herramientas básicas
RUN apt update && apt install -y \
    curl gnupg wget unzip openjdk-17-jdk \
    git nodejs npm zip

# Instalar node 18
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && npm i -g npm@10

# Instalar Bubblewrap
RUN npm i -g @bubblewrap/cli

# Instalar Android SDK y Build Tools
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0:$PATH

RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    cd $ANDROID_HOME/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -O tools.zip && \
    unzip tools.zip && rm tools.zip && mv cmdline-tools latest && \
    yes | sdkmanager --sdk_root=$ANDROID_HOME --licenses && \
    sdkmanager --sdk_root=$ANDROID_HOME \
      "platform-tools" \
      "platforms;android-34" \
      "build-tools;34.0.0"

ENTRYPOINT ["/entrypoint.sh"]
