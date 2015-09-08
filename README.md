#Senspark Plugins

Senspark Plugin provides common utilities for developers to use in game across different platforms with [cocos2d-x](https://github.com/cocos2d/cocos2d-x).

This plugin is developed basing on [__Plugin-x__](https://github.com/cocos2d-x/plugin-x), which provides an easy way for developers to integrate various third party SDKs.

## Highlights
One unified API for all SDKs

* Ads
* Analytics
* BaaS (Backend as a Service)
* Data
* IAP (comming soon)
* Sharing
* Social 

## How To Contribute

1. Prerequisites
	- Define environment variable `COCOS2DX_ROOT` in `/etc/launchd.conf` ([using this help](http://stackoverflow.com/questions/135688/setting-environment-variables-in-os-x/588442#588442))
	- Put this line in ~/.profile file
	
			grep -E "^setenv" /etc/launchd.conf | xargs -t -L 1 launchctl

2. ...


## How To Use
### 1. Analytics

- **Providers**
	- Flurry Analytics 
	- Google Analytics 

- **Using**
	- Example
			
			auto manager = SensparkPluginManager::getInstance();
			
			auto pluginProtocol = manager->loadAnalyticsPlugin(AnalyticsPluginType::GOOGLE_ANALYTICS);
		
			auto googleAnalytics = static_cast<GoogleProtocolAnalytics*>(pluginProtocol) 


### 2. Ads

- **Providers**
	- Admob
	- AdColony
	- Facebook Ads
	- Tapjoy
	- Vungle
- **Using**
	- Example
			
			auto manager = SensparkPluginManager::getInstance();
			
			auto pluginProtocol = manager->loadAnalyticsPlugin(AdsPluginType::ADMOB);
		
			auto admobAd = static_cast<AdmobProtocolAds*>(pluginProtocol) 

### 3. BaaS
### 4. Data
### 5. IAP
### 6. Sharing
### 7. Social