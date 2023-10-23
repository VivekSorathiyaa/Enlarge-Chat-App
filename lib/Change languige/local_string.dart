import 'package:get/get.dart';

class LocaleString extends Translations{
  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys => {
    //ENGLISH LANGUAGE
    'en_US':{
      'head':'Chat App',
      'people':'People',
      'myProfile':'My Account',
      'chats':'Chats',
      'theme':'Theme',
      'changeLang':'Change Language',
      'logOut':'Log Out',
      'logout_desc':'Would you like to continue to logout?',
      'continue':'Continue',
      'cancel':'Cancel',
      'search':'Search',
      'phone':'Phone Number',
      'chooseLang':'Choose Your Language'
    },
    //HINDI LANGUAGE
    'hi_IN':{
      'head': 'चैट ऐप',
      'people':'लोग',
      'myProfile':'मेरा खाता',
      'chats':'चैट',
      'theme':'विषय',
      'changeLang':'भाषा बदलो',
      'logOut':'लॉग आउट',
      'logout_desc':'क्या आप लॉगआउट जारी रखना चाहेंगे?',
      'continue' :'जारी रखना',
      'cancel':'रद्द करना',
      'search':'खोज',
      'phone':'फ़ोन नंबर',
      'chooseLang':'अपनी भाषा चुनें'

    },
    //KANNADA LANGUAGE
    'gu_IN':{
      'head': 'ચેટ એપ્લિકેશન',
      'people':'લોકો',
      'myProfile':'મારું ખાતું',
      'chats':'ચેટ્સ',
      'theme':'થીમ',
      'changeLang':'ભાષા બદલો',
      'logOut':'લોગ આઉટ',
      'logout_desc':'શું તમે લોગઆઉટ કરવાનું ચાલુ રાખવા માંગો છો?',
     'continue':'ચાલુ રાખો',
      'cancel':'રદ કરો',
      'search':'શોધો',
      'phone':'ફોન નંબર',
      'chooseLang':'તમારી ભાષા પસંદ કરો'
    }
  };

}