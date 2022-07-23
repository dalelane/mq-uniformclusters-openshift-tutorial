package com.ibm.clientengineering.mq.samples;

public class Config {
    public static final String QMGRNAME = "*DEMOCLUSTER";
    public static final String QUEUE = "APPQ1";
    public static final String CCDT_LOCATION = "/opt/app/config/ibm-mq-ccdt.json";

    // OpenShift will give the pod a unique hostname, so we can use this
    //  as a proxy for a unique client id
    public static final String CLIENTID = System.getenv("HOSTNAME");

    public static void setupTls() {
        System.setProperty("javax.net.ssl.trustStore", "/opt/app/truststore.jks" );
        System.setProperty("javax.net.ssl.keyStore", "/opt/app/keystore.jks" );
        System.setProperty("javax.net.ssl.keyStorePassword", "passw0rd" );
        System.setProperty("com.ibm.mq.cfg.useIBMCipherMappings", "false");
    }
}
