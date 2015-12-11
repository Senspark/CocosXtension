//
//  JSonUtils.h
//  BirdJumpJump
//
//  Created by Duc Nguyen on 11/13/14.
//
//

#ifndef __BirdJumpJump__JSonUtils__
#define __BirdJumpJump__JSonUtils__

#include <stdio.h>
#include "cocos2d.h"
#include "external/rapidjson/rapidjson.h"
#include "external/rapidjson/document.h"

USING_NS_CC;

namespace senspark {

class JsonUtils {
public:
    static Value    parseValueFromJsonValue(const rapidjson::Value& value);
    static ValueMap parseValueMapFromJsonFile(const std::string& filename);
    static ValueMap parseValueMapFromJsonContent(const std::string& content);
    static ValueVector parseValueVectorFromJsonContent(const std::string& content);
};

}
#endif /* defined(__BirdJumpJump__JSonUtils__) */
