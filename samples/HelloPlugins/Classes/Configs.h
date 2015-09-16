#ifndef __CONFIGS_H__
#define __CONFIGS_H__

/** @warning
 * The file UCGameSDK.jar conflicts with weiboSDK.jar
 * if you want test the login/logout of UC,
 * modify the android project config: remove the weiboSDK.jar, and add UCGameSDK.jar
*/
#define TEST_UC             0

#define APP_NAME                "HelloPlugins"

/**
 @brief Senspark namespace
 */
#define NS_SENSPARK_BEGIN       namespace senspark {
#define NS_SENSPARK_END         }
#define USING_NS_SENSPARK       using namespace senspark;

/**
 @brief Developer information of Google Play
 */
#define GOOGLE_PLAY_KEY_IOS     "972910531858-sj6n2joc4l35lqboc9vtsjlh3hasona0.apps.googleusercontent.com"
#define GOOGLE_PLAY_KEY_ANDROID "972910531858"

#define GOOGLE_PLAY_LEADERBOARD_KEY_IOS_EASY    "CgkIkqryr6gcEAIQAg"
#define GOOGLE_PLAY_LEADERBOARD_KEY_IOS_HARD    "CgkIkqryr6gcEAIQAw"

#define GOOGLE_PLAY_ACHIEVEMENT_KEY_IOS_PRIME   "CgkIkqryr6gcEAIQBA"
/**
 @brief Developer information of Game Center
 */

#define GAME_CENTER_LEADERBOARD_KEY_IOS_EASY    "com.senspark.cocos2dx.plugin.test_easy"
#define GAME_CENTER_LEADERBOARD_KEY_IOS_HARD    "com.senspark.cocos2dx.plugin.test_hard"

#define GAME_CENTER_ACHIEVEMENT_KEY_IOS_PRIME   "com.senspark.cocos2dx.plugin.test_achievement.prime"

/**
 @brief Developer information of Parse
 */
#define PARSE_APPLICATION_ID    "QT17zRDa4jKWU6yOFwsI0UsR3jZXZZwUDLmvE2OT"
#define PARSE_CLIENT_KEY        "hxB9QyV0ptmGpnEqVLawpaQtgY94eAHH6cwjKT7N"

/**
 @brief Developer information of flurry
 */
#define FLURRY_KEY_IOS          "KMGG7CD9WPK2TW4X9VR8"
#define FLURRY_KEY_ANDROID      "SPKFH8KMPGHMMBWRBT5W"

/**
 @brief Developer information of google analytics
 */
#define GOOGLE_ANALYTICS_KEY_IOS            "UA-65216593-1"
#define GOOGLE_ANALYTICS_KEY_ANDROID        "UA-65216593-1"

/**
 @brief Developer information of facebook
 */
#define FACEBOOK_KEY_IOS          "281024655411962_324933371021090"
#define FACEBOOK_KEY_ANDROID      "281024655411962_326911607489933"

/**
 @brief Developer information of Umeng
 */
#define UMENG_KEY_IOS           "50d2b18c5270152187000097"
#define UMENG_KEY_ANDROID       ""          // umeng key for android is setted in AndroidManifest.xml

/**
 @brief Developer information of Admob
 */
#define ADMOB_ID_IOS            "a1517500cc8f794"
#define ADMOB_ID_ANDROID        "a1516fb6b16b12f"

/**
 @brief Developer information of Nd91
 */
#define ND91_APPID              "100010"
#define ND91_APPKEY             "C28454605B9312157C2F76F27A9BCA2349434E546A6E9C75";
#define ND91_ORIENTATION        "landscape"

#define GOOGLE_APPKEY			"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlWwOhjGZx/FQ9vP8GX8ONrtXBQcEs7QRmXQNGx4lRiMSta+QvSVP/6kzWqLNr/2QpzLlyLXWZaymCgxD/N7RP3X7lTj/PiKfPuG60pj7zgooTDrzu7gJz1YB3xSqnG+7/jCk58LhN8QzPd/Vwkr/5ejge67KNdCRJaI13IK3e5OSEd3QnnqgX/43H1Morr5bDs1TXPMKy59+eO5iumf0U/pm58CBllx/g4u142Nqjn5Pn+Ji4IWuAeFl7sk5J9XLqSsxd/IzOsLmIB8JsatjTM2o+B+fWD/Dokjf79fIoIe1KxsMIKXkXXwVyxoERuqQpETp02NUBaumAk0fL0D/kwIDAQAB"

/**
 @brief Developer information of QH360
 */
#define QH360_EXCHANGE_RATE     "1"

/**
 @brief Developer information of UC
 */
#define UC_CPID                 "20087"
#define UC_GAME_ID              "119474"
#define UC_SERVER_ID            "1333"

#endif // __CONFIGS_H__
