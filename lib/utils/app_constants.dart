import 'package:flutter/foundation.dart' as app;
import 'dart:io' show Platform;

class AppConstants {
  // static String apiBaseURL = "http://192.168.29.4:8888/"; //sanket
  // static String apiBaseURL = "http://192.168.29.54:8005/api/"; //gaurav

  static String apiBaseURL = "https://enlargesoftithub.com/scs-rajkot/api/"; //live
  static const String googleMapAPIKey = 'YOUR_API_KEY_HERE';

  // Customer
  static const String customerUserLogin = 'customer-login';
  static const String customerLogout = 'customer-logout';
  static const String customerUserSignUp = 'signup';
  static const String getSampleFrequencyList = 'get-sample-frequency-list';
  static const String getCustomerProfile = 'get-customer-profile';
  static const String updateCustomerProfile = 'update-customer-profile';
  static const String updateContactDetails = 'update-contact-details';
  static const String deleteContact = 'delete-contact';
  static const String addContact = 'add-contact-details';
  static const String reTestingAdd = 're-testing-add';
  static const String sampleCollectionRequestSend =
      'sample-collection-request-send';

  // Admin
  static const String adminUserLogin = 'admin/login';
  static const String adminLogout = 'admin/logout';
  static const String getAdminCustomerList = 'get-customer-list';
  static const String getAdminUnassignedList = 'get-unassigned-list';
  static const String getAdminCollectionPendingList = 'collection-pending-list';
  static const String getAdminCustomerDetails = 'customer-details';
  static const String assignRoute = 'assign-route';
  static const String getRouteList = 'get-route-list';
  static const String adminProfile = 'get-admin-profile';
  static const String getAdminCollectedList = 'collected-list';

  // Sample
  static const String employeeLogin = 'employee-login';
  static const String getRouteRequestList = 'route-request-list';
  static const String getSampleRouteWiseList = 'sample-route-wise-list';
  static const String getSampleProfile = 'employee-profile';
  static const String sampleLogout = 'employee-logout';
  static const String updateSampleProfile = 'update-employee-profile';
  static const String sampleCollected = 'sample-collected';
  static const String changePriority = 'change-priority';

}
