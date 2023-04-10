 import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService{
  static Future<void> initializeNotification() async {
   await AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
     null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max
          ,channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,

        ),
      ],
     
    );


    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

  
  }

  
 }