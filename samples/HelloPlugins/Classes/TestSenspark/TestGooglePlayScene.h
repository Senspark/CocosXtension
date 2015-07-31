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
#ifndef __TEST_USER_SCENE_H__
#define __TEST_USER_SCENE_H__

#include "cocos2d.h"
#include "ListLayer.h"
#include "GooglePlayProtocolUser.h"
#include "GooglePlayProtocolSocial.h"
#include "ProtocolUser.h"
#include <string>

USING_NS_SENSPARK_PLUGIN_USER;
USING_NS_SENSPARK_PLUGIN_SOCIAL;
USING_NS_SENSPARK;

class TestGooglePlay : public ListLayer
{
public:
    // Here's a difference. Method 'init' in cocos2d-x returns bool, instead of returning 'id' in cocos2d-iphone
    virtual bool init();  

    // there's no 'id' in cpp, so we recommend returning the class instance pointer
    static cocos2d::Scene* scene();

    // implement the "static node()" method manually
    CREATE_FUNC(TestGooglePlay);
    
    void doAction(int tag);
    
    void onUserCallback(int code, std::string& msg);
    void onSocialCallback(int code, std::string& msg);

private:
    GooglePlayProtocolUser* _protocolGooglePlayUser;
    GooglePlayProtocolSocial* _protocolGooglePlaySocial;
    
    Label* _resultInfo;
    
};

#endif // __TEST_USER_SCENE_H__
