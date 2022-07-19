package com.ibm.clientengineering.mq.samples;

import java.io.File;
import java.util.Date;

import javax.jms.Connection;
import javax.jms.Destination;
import javax.jms.Message;
import javax.jms.MessageProducer;
import javax.jms.Session;

import com.ibm.mq.jms.MQConnectionFactory;
import com.ibm.msg.client.wmq.WMQConstants;


public class Putter {
    public static void main(String[] args) {
        System.out.println("Starting PUTTER with client id " + Config.CLIENTID);

        Config.setupTls();

        Connection connection = null;
        Session session = null;
        Destination destination = null;
        MessageProducer producer = null;

        try {
            File ccdtfile = new File(Config.CCDT_LOCATION);

            MQConnectionFactory cf = new MQConnectionFactory();
            cf.setCCDTURL(ccdtfile.toURI().toURL());
            cf.setQueueManager(Config.QMGRNAME);
            cf.setClientReconnectOptions(WMQConstants.WMQ_CLIENT_RECONNECT);
            cf.setClientID(Config.CLIENTID);
            cf.setAppName("test-putter");

            connection = cf.createConnection();
            session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);

            destination = session.createQueue(Config.QUEUE);
            producer = session.createProducer(destination);

            connection.start();

            while (true) {
                String messagestring = Config.CLIENTID + ": " + new Date().toString();
                Message message = session.createTextMessage(messagestring);
                producer.send(message);

                System.out.println("sent <" + messagestring + ">");

                Thread.sleep(400);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
}
