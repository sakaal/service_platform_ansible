# /etc/profile.d/maven.sh

MAVEN_OPTS="-Dhttps.protocols=TLSv1,TLSv1.1,TLSv1.2 -Djavax.net.ssl.trustStore=/etc/pki/java/cacerts -Djavax.net.ssl.trustStorePassword=changeit"
export MAVEN_OPTS
