/****************************************************************************
Copyright (c) 2012-2013 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#include "ProtocolSocial.h"
#include "PluginUtilsIOS.h"
#import "InterfaceSocial.h"

namespace cocos2d { namespace plugin {

ProtocolSocial::ProtocolSocial()
{
}

ProtocolSocial::~ProtocolSocial()
{
    PluginUtilsIOS::erasePluginOCData(this);
}

void ProtocolSocial::configDeveloperInfo(TSocialInfo devInfo)
{
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != NULL);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceSocial)]) {
        NSObject<InterfaceSocial>* curObj = ocObj;
        NSMutableDictionary* pDict = PluginUtilsIOS::createDictFromMap(&devInfo);
        [curObj configDeveloperInfo:pDict];
    }
}
    
void ProtocolSocial::submitScore(const std::string& leadboardID, int score, const SocialCallback& cb)
{
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != NULL);

    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceSocial)]) {
        NSObject<InterfaceSocial>* curObj = ocObj;
        
        CallbackWrapper *wrapper = new CallbackWrapper(cb);
        
        NSString* pID = [NSString stringWithUTF8String:leadboardID.c_str()];
        [curObj submitScore:pID withScore:score withCallback:(long)wrapper];
    }
}

void ProtocolSocial::showLeaderboard(const std::string& leaderboardID, const DialogCallback& cb)
{
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != NULL);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceSocial)]) {
        NSObject<InterfaceSocial>* curObj = ocObj;
        
        CallbackWrapper* wrapper = new CallbackWrapper(cb);
        
        NSString* pID = [NSString stringWithUTF8String:leaderboardID.c_str()];
        [curObj showLeaderboard:pID withCallback:(long) wrapper];
    }
}
    
void ProtocolSocial::showLeaderboards(const DialogCallback &cb) {
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != NULL);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceSocial)]) {
        NSObject<InterfaceSocial>* curObj = ocObj;
        
        CallbackWrapper* wrapper = new CallbackWrapper(cb);
        
        [curObj showLeaderboards:(long) wrapper];
    }
}

void ProtocolSocial::unlockAchievement(TAchievementInfo achInfo, const SocialCallback &cb)
{

    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != NULL);

    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceSocial)]) {
        NSObject<InterfaceSocial>* curObj = ocObj;
        
        CallbackWrapper* wrapper = new CallbackWrapper(cb);
        
        NSMutableDictionary* pDict = PluginUtilsIOS::createDictFromMap(&achInfo);
        [curObj unlockAchievement:pDict withCallback:(long) wrapper];
    }
}

void ProtocolSocial::showAchievements(const DialogCallback &cb)
{
    PluginOCData* pData = PluginUtilsIOS::getPluginOCData(this);
    assert(pData != NULL);
    
    id ocObj = pData->obj;
    if ([ocObj conformsToProtocol:@protocol(InterfaceSocial)]) {
        NSObject<InterfaceSocial>* curObj = ocObj;
        
        CallbackWrapper* wrapper = new CallbackWrapper(cb);
        
        [curObj showAchievements:(long) wrapper];
    }
}

}} // namespace cocos2d { namespace plugin {
