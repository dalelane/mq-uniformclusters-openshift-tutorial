package com.ibm.clientengineering.mq.samples;

import java.io.File;

import javax.jms.Connection;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.Queue;
import javax.jms.Session;

import com.ibm.mq.jms.MQConnectionFactory;
import com.ibm.msg.client.wmq.WMQConstants;


public class Getter {
    public static void main(String[] args) {
        System.out.println("Starting GETTER with client id " + Config.CLIENTID);

        Config.setupTls();

        Connection connection = null;
        Session session = null;
        Queue destination = null;
        MessageConsumer consumer = null;

        try {
            File ccdtfile = new File(Config.CCDT_LOCATION);

            MQConnectionFactory cf = new MQConnectionFactory();
            cf.setCCDTURL(ccdtfile.toURI().toURL());
            cf.setQueueManager(Config.QMGRNAME);
            cf.setClientReconnectOptions(WMQConstants.WMQ_CLIENT_RECONNECT);
            cf.setClientID(Config.CLIENTID);
            cf.setAppName("test-getter");
            cf.setSyncpointAllGets(false);

            connection = cf.createConnection();
            session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);

            destination = session.createQueue(Config.QUEUE);
            consumer = session.createConsumer(destination);

            connection.start();

            while (true) {
                try {
                    Message message = consumer.receive();
                    if (message != null) {
                        System.out.println(message.getBody(String.class));
                    }
                }
                catch (JMSException jmse) {
                    System.err.println("receive error " + jmse.getErrorCode());
                }
                catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
}
