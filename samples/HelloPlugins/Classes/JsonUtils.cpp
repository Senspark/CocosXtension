//
//  JSonUtils.cpp
//  BirdJumpJump
//
//  Created by Duc Nguyen on 11/13/14.
//
//

#include "JSonUtils.h"

using namespace senspark;

Value JsonUtils::parseValueFromJsonValue(const rapidjson::Value &value) {
    auto t = value.GetType();
    
    if (t == rapidjson::Type::kFalseType) {
        return Value(false);
    }
    
    if (t == rapidjson::Type::kTrueType) {
        return Value(true);
    }
    
    if (t == rapidjson::Type::kStringType) {
        return Value(value.GetString());
    }
    
    if(t == rapidjson::Type::kNumberType) {
        if(value.IsDouble()) {
            return Value(value.GetDouble());
        } else if(value.IsUint()) {
            int temp = value.GetUint();
            return Value(temp);
        } else if(value.IsInt()) {
            return Value(value.GetInt());
        }
    }
    
    if(t == rapidjson::Type::kObjectType) {
        ValueMap dict;
        for (rapidjson::Value::ConstMemberIterator itr = value.MemberBegin(); itr != value.MemberEnd(); ++itr)
        {
            auto jsonKey = itr->name.GetString();
            auto el = parseValueFromJsonValue(itr->value);
            dict[jsonKey] = el;
        }
        return Value(dict);
    }
    if(t == rapidjson::Type::kArrayType) {
        ValueVector arr;
        for (rapidjson::SizeType i = 0; i < value.Size(); i++)
        {
            //CCLOG("%d ", itr->GetInt());
            auto el = parseValueFromJsonValue(value[i]);
            arr.push_back(el);
        }
        return Value(arr);
    }
    
    // none
    return Value();
}

ValueMap JsonUtils::parseValueMapFromJsonFile(const std::string &filename) {
    auto content = FileUtils::getInstance()->getStringFromFile(filename);
    
    return parseValueMapFromJsonContent(content);
}

ValueMap JsonUtils::parseValueMapFromJsonContent(const std::string& content)
{
    rapidjson::Document doc;
    doc.Parse<0>(content.c_str());
    if (! doc.HasParseError())
    {
        // check that root is object not array
        auto val = parseValueFromJsonValue(doc);
        // should check here or have caller check if actually map
        return val.asValueMap();
    }
    
    CCLOG("GetParseError: %u\n", doc.GetParseError());
    return ValueMapNull;
}

ValueVector JsonUtils::parseValueVectorFromJsonContent(const std::string& content) {
    rapidjson::Document doc;
    doc.Parse<0>(content.c_str());
    if (! doc.HasParseError())
    {
        auto val = parseValueFromJsonValue(doc);
        return val.asValueVector();
    }
    
    CCLOG("GetParseError: %u\n", doc.GetParseError());
    return ValueVectorNull;
}