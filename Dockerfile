FROM ubuntu:22.04

USER root

# Copiar entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Instalar dependencias base
RUN apt update && apt install -y \
    curl gnupg wget unzip openjdk-17-jdk \
    git zip

# Instalar Node.js 18 y npm 10
RUN apt-get remove -y nodejs npm || true
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@10

# Instalar Bubblewrap
RUN npm install -g @bubblewrap/cli

# Variables del SDK
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0:$PATH

# Instalar Android SDK + Build Tools + Licencias
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
