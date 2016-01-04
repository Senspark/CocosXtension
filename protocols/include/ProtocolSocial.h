/****************************************************************************
Copyright (c) 2013 cocos2d-x.org

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
#ifndef  __CCX_PROTOCOL_SOCIAL_H__
#define  __CCX_PROTOCOL_SOCIAL_H__

#include "PluginProtocol.h"
#include <map>
#include <string>
#include <functional>

namespace cocos2d { namespace plugin {

typedef std::map<std::string, std::string> TSocialInfo;
typedef std::map<std::string, std::string> TAchievementInfo;

class ProtocolSocial : public PluginProtocol
{
public:
    ProtocolSocial();
    virtual ~ProtocolSocial();

	typedef std::function<void(bool, const std::string&)> SocialCallback;
    typedef std::function<void()> DialogCallback;
    
    typedef struct __CallbackWrapper {
        __CallbackWrapper(const SocialCallback& cb) {
            callbackSocialPtr = cb;
        }
        
        __CallbackWrapper(const DialogCallback& cb) {
            callbackDialogPtr = cb;
        }
        
        SocialCallback callbackSocialPtr;
        DialogCallback callbackDialogPtr;
        
    } CallbackWrapper;
    
    /**
    @brief config the share developer info
    @param devInfo This parameter is the info of developer,
           different plugin have different format
    @warning Must invoke this interface before other interfaces.
             And invoked only once.
    */
    void configDeveloperInfo(TSocialInfo devInfo);

    /**
     * @brief methods of leaderboard feature
     */
    void submitScore(const std::string& leadboardID, int score, const SocialCallback& cb);
    
    void showLeaderboard(const std::string& leaderboardID, const DialogCallback& cb);
    void showLeaderboards(const DialogCallback& cb);
    /**
     * @brief methods of achievement feature
     */
    void unlockAchievement(TAchievementInfo achInfo, const SocialCallback& cb);
    
    void showAchievements(const DialogCallback& cb);
};

}} // namespace cocos2d { namespace plugin {

#endif   /* ----- #ifndef __CCX_PROTOCOL_SOCIAL_H__ ----- */
