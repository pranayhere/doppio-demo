#!/bin/bash
set -e

# Use these vars to control which of the optional Java programs are downloaded.
INSTALL_ECJ=true
INSTALL_BEANSHELL=false

cd `dirname $0`/..

PLATFORM=`uname -s`
PKGMGR=""

if [ "$PLATFORM" = "Darwin" ]; then
    if command -v brew; then
        echo "Found the homebrew package manager."
        PKGMGR="brew install"
    fi
fi

if ! command -v wget >/dev/null && [ -n "$PKGMGR" ]; then
    $PKGMGR wget
fi

cd vendor

# check for the JCL
# Ubuntu (security) repo actual on 24.02.2013
if [ ! -f classes/java/lang/Object.class ]; then
  DOWNLOAD_DIR=`mktemp -d jdk-download.XXX`
  cd $DOWNLOAD_DIR
    DEBS_DOMAIN="http://security.ubuntu.com/ubuntu/pool/main/o/openjdk-6"
    DEBS=("openjdk-6-jre-headless_6b27-1.12.5-0ubuntu0.12.04.1_i386.deb"
          "openjdk-6-jdk_6b27-1.12.5-0ubuntu0.12.04.1_i386.deb"
          "openjdk-6-jre-lib_6b27-1.12.5-0ubuntu0.12.04.1_all.deb")
    for DEB in ${DEBS[@]}; do
      wget $DEBS_DOMAIN/$DEB
      ar p $DEB data.tar.gz | tar zx
    done
  cd ..
  JARS=("rt.jar" "tools.jar" "resources.jar" "rhino.jar" "jsse.jar")
  for JAR in ${JARS[@]}; do
    JAR_PATH=`find $DOWNLOAD_DIR/usr -name $JAR | head -1`
    echo "Extracting the Java class library from $JAR_PATH"
    unzip -qq -o -d classes/ "$JAR_PATH"
  done
  if [ ! -e java_home ]; then
    JH=$DOWNLOAD_DIR/usr/lib/jvm/java-6-openjdk-common/jre
    # a number of .properties files are symlinks to /etc; copy the targets over
    # so we do not need to depend on /etc's existence
    for LINK in `find $JH -type l`; do
      DEST=`readlink $LINK`
      if [ "`expr "$DEST" : '/etc'`" != "0" ]; then
        test -e "$DOWNLOAD_DIR/$DEST" && mv "$DOWNLOAD_DIR/$DEST" $LINK
      fi
    done
    mv $JH java_home
  fi
  rm -rf "$DOWNLOAD_DIR"
fi

# check for jazzlib
if [ ! -f classes/java/util/zip/DeflaterEngine.class ]; then
  echo "patching the class library with Jazzlib"
  mkdir -p jazzlib && cd jazzlib
  wget -q "http://downloads.sourceforge.net/project/jazzlib/jazzlib/0.07/jazzlib-binary-0.07-juz.zip"
  unzip -qq "jazzlib-binary-0.07-juz.zip"

  cp java/util/zip/*.class ../classes/java/util/zip/
  cd .. && rm -rf jazzlib
fi

#### Optional JARs ####

# Eclipse standalone compiler
# Example uses:
#   java -classpath vendor/classes org.eclipse.jdt.internal.compiler.batch.Main A.java
# With Doppio: (see issue #218)
#   ./doppio -Djdt.compiler.useSingleThread -jar vendor/jars/ecj.jar -1.6 classes/demo/Fib.java
if [ $INSTALL_ECJ && ! -f jars/ecj.jar ]; then
  ECJ_JAR_URL="http://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops/R-3.7.1-201109091335/ecj-3.7.1.jar"
  mkdir -p jars
  wget -O jars/ecj.jar $ECJ_JAR_URL
  unzip -qq -o -d classes/ jars/ecj.jar
fi

cd ..  # back to start

echo "Your environment should now be set up correctly."
echo "Run './tools/webrick.rb' start the demo server."
