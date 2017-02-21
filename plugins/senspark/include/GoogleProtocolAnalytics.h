//
//  GoogleProtocolAnalytics.h
//  PluginSenspark
//
//  Created by Duc Nguyen on 7/16/15.
//  Copyright (c) 2015 Senspark Co., Ltd. All rights reserved.
//

#ifndef PluginSenspark_GoogleProtocolAnalytics_h
#define PluginSenspark_GoogleProtocolAnalytics_h

#include <map>
#include <string>
#include <vector>

#include "ProtocolAnalytics.h"
#include "SensparkPluginMacros.h"

NS_SENSPARK_PLUGIN_ANALYTICS_BEGIN
enum class GALogLevel {
    NONE = 0,
    ERROR = 1,
    WARNING = 2,
    INFO = 3,
    VERBOSE = 4
};

class Product;
class ProductAction;

class HitBuilders {
private:
    template <class T> class Internal;

public:
    class ScreenViewBuilder;
    class ExceptionBuilder;
    class TimingBuilder;
    class SocialBuilder;
    class EventBuilder;
};

/// https://developers.google.com/android/reference/com/google/android/gms/analytics/ecommerce/Product
/// Class to construct product related information for a Google Analytics hit.
/// Use this class to report information about products sold by merchants or
/// impressions of products seen by users.
/// Instances of this class can be associated with both ProductActions via @c
/// addProduct(Product) and Product Impressions via @c addImpression(Product,
/// String).
class Product {
public:
    template <class T> friend class HitBuilders::Internal;

    /// Sets the category associated with the product in GA reports.
    /// @param value The product's category. Example: "Toys"
    /// @return Returns the same object to enable chaining of methods.
    Product& setCategory(const std::string& value);

    /// Sets the id that is used to identify a product in GA reports.
    /// @param value The product id.
    /// @return Returns the same object to enable chaining of methods.
    Product& setId(const std::string& value);

    /// Sets the name that is used to identify the product in GA reports.
    /// @param value The product's name. Example: "Space Monkeys"
    /// @return Returns the same object to enable chaining of methods.
    Product& setName(const std::string& value);

    /// Sets the price of the product.
    /// @param value The product's price. Example: 3.14
    /// @return Returns the same object to enable chaining of methods.
    Product& setPrice(float price);

private:
    std::map<std::string, std::string> dict_;
};

/// https://developers.google.com/android/reference/com/google/android/gms/analytics/ecommerce/ProductAction
/// Class to construct transaction/checkout or other product interaction related
/// information for a Google Analytics hit. Use this class to report information
/// about products sold, viewed or refunded. This class is intended to be used
/// with Product. Instances of this class can be associated with @c
/// setProductAction(ProductAction).
class ProductAction {
public:
    template <class T> friend class HitBuilders::Internal;

    /// Action to use when a product is added to the cart.
    /// Constant Value: "add"
    static const std::string ActionAdd;

    /// Action to use for hits with checkout data. This action can have
    /// accompanying fields like checkout step @c setCheckoutStep(int), checkout
    /// label @c setCheckoutOptions(String) and checkout options
    /// @c setCheckoutOptions(String).
    /// Constant Value: "checkout"
    static const std::string ActionCheckout;

    /// Action to use when the user clicks on a set of products. This action can
    /// have accompanying fields like product action list name
    /// setProductActionList(String) and product list source
    /// setProductListSource(String).
    /// Constant Value: "click"
    static const std::string ActionClick;

    /// Action to use when the user views detailed descriptions of products.
    /// This action can have accompanying fields like product action list name
    /// setProductActionList(String) and product list source
    /// setProductListSource(String).
    /// Constant Value: "detail"
    static const std::string ActionDetail;

    /// Action that is used to report all the transaction data to GA. This is
    /// equivalent to the transaction hit type which was available in previous
    /// versions of the SDK. This action can can also have accompanying fields
    /// like transaction id, affiliation, revenue, tax, shipping and coupon
    /// code. These fields can be specified with methods defined in this class.
    /// Constant Value: "purchase"
    static const std::string ActionPurchase;

    /// Sets the product action for all the products included in the hit. Valid
    /// values include "detail", "click", "add", "remove", "checkout",
    /// "checkout_option", "purchase" and "refund". All these values are also
    /// defined in this class for ease of use. You also also send additional
    /// values with the hit for some specific actions. See the action
    /// documentation for details.
    /// @param action The value of product action.
    explicit ProductAction(const std::string& action);

    /// Sets the list name associated with the products in the analytics hit.
    /// This value is used with ACTION_DETAIL and ACTION_CLICK actions.
    /// @param value A string name identifying the product list.
    /// @return Returns the same object to enable chaining of methods.
    ProductAction& setProductActionList(const std::string& value);

    /// Sets the list source name associated with the products in the analytics
    /// hit. This value is used with ACTION_DETAIL and ACTION_CLICK actions.
    /// @param value A string name identifying the product list's source.
    /// @return Returns the same object to enable chaining of methods.
    ProductAction& setProductListSource(const std::string& value);

    /// The unique id associated with the transaction. This value is used for
    /// ACTION_PURCHASE and ACTION_REFUND actions.
    /// @param value A string id identifying a transaction.
    /// @return Returns the same object to enable chaining of methods.
    ProductAction& setTransactionId(const std::string& value);

    /// Sets the transaction's total revenue. This value is used for
    /// ACTION_PURCHASE and ACTION_REFUND actions.
    /// @param value A number representing the revenue from a transaction.
    /// @return Returns the same object to enable chaining of methods.
    ProductAction& setTransactionRevenue(float value);

private:
    std::map<std::string, std::string> dict_;
};

/// https://developers.google.com/android/reference/com/google/android/gms/analytics/HitBuilders.HitBuilder
/// Internal class to provide common builder class methods. The most
/// important methods from this class are the setXYZ and build methods.
/// These methods can be used to set individual properties on the hit and
/// then build it so that it is ready to be passed into the tracker.
template <class T> class HitBuilders::Internal {
public:
    /// Adds a product impression to the hit. The product can be optionally
    /// associated with a named impression list.
    T& addImpression(const Product& product, const std::string& impressionList);

    /// Adds product information to be sent with a given hit. The action
    /// provided in @c setProductAction(ProductAction) affects how the
    /// products passed in through this method get processed.
    T& addProduct(const Product& product);

    /// Sets a product action for all the products included in this hit. The
    /// action and its associated properties affect how the products added
    /// through @c addProduct(Product) are processed.
    T& setProductAction(const ProductAction& action);

    /// Sets the value for the given parameter name.
    /// @param paramName The name of the parameter that should be sent over
    /// wire. This value should start with "&".
    /// @param paramValue The value to be sent over the wire for the given
    /// parameter.
    T& set(const std::string& paramName, const std::string& paramValue);

    /// Adds a custom dimension to the current hit builder. Calling this
    /// method with the same index will overwrite the previous dimension
    /// with the new one.
    /// @param index The index/slot in which the dimension will be set.
    /// @param dimension The value of the dimension for the given index.
    T& setCustomDimenstion(std::size_t index, const std::string& dimension);

    /// Adds a custom metric to the current hit builder. Calling this method
    /// with the same index will overwrite the previous metric with the new
    /// one.
    /// @param index The index/slot in which the dimension will be set.
    /// @param metric The value of the metric for the given index.
    T& setCustomMetric(std::size_t index, float metric);

    /// Builds a Map of parameters and values that can be set on the Tracker
    /// object.
    /// @return A map of string keys to string values that can be passed
    /// into the tracker for one or more hits.
    std::map<std::string, std::string> build() const;

protected:
    /// Sets the type of the hit to be sent. This can be used to reuse the
    /// builder object for multiple hit types.
    /// @param hitType The value of the Hit.
    T& setHitType(const std::string& hitType);

private:
    std::map<std::string, std::string> dict_;
    std::vector<ProductAction> productAction_; /// Actually contains 1 object.
    std::vector<Product> products_;
    std::map<std::string, std::vector<Product>> impressions_;
};

/// https://developers.google.com/android/reference/com/google/android/gms/analytics/HitBuilders.ScreenViewBuilder
/// Class to build a screen view hit. You can add any of the other fields to
/// the builder using common set and get methods.
class HitBuilders::ScreenViewBuilder : public Internal<ScreenViewBuilder> {
public:
    ScreenViewBuilder();
};

/// https://developers.google.com/android/reference/com/google/android/gms/analytics/HitBuilders.ExceptionBuilder
/// Exception builder allows you to measure the number and type of caught
/// and uncaught crashes and exceptions that occur in your app.
class HitBuilders::ExceptionBuilder : public Internal<ExceptionBuilder> {
public:
    ExceptionBuilder();
    ExceptionBuilder& setDescription(const std::string& description);
    ExceptionBuilder& setFatal(bool fatal);
};

/// https://developers.google.com/android/reference/com/google/android/gms/analytics/HitBuilders.TimingBuilder
/// Hit builder used to collect timing related data. For example, this hit
/// type can be useful to measure resource load times. For meaningful data,
/// at least the category and the value should be set before sending the
/// hit.
class HitBuilders::TimingBuilder : public Internal<TimingBuilder> {
public:
    TimingBuilder();

    /// Convenience constructor for creating a timing hit. Additional fields
    /// can be specified using the setter methods.
    /// @param category The type of variable being measured. Example:
    /// AssetLoader
    /// @param variable The variable being measured. Example:
    /// AssetLoader.load
    /// @param value The value associated with the variable. Example: 1000
    TimingBuilder(const std::string& category, const std::string& variable,
                  int value);

    TimingBuilder& setVariable(const std::string& variable);
    TimingBuilder& setValue(int value);
    TimingBuilder& setCategory(const std::string& category);
    TimingBuilder& setLabel(const std::string& label);
};

/// https://developers.google.com/android/reference/com/google/android/gms/analytics/HitBuilders.SocialBuilder
/// A Builder object to build social event hits. See https://goo.gl/iydW9O
/// for description of all social fields.
class HitBuilders::SocialBuilder : public Internal<SocialBuilder> {
public:
    SocialBuilder();
    SocialBuilder& setNetwork(const std::string& network);
    SocialBuilder& setAction(const std::string& action);
    SocialBuilder& setTarget(const std::string& target);
};

/// https://developers.google.com/android/reference/com/google/android/gms/analytics/HitBuilders.EventBuilder
/// A Builder object to build event hits. For meaningful data, event hits
/// should contain at least the event category and the event action.
class HitBuilders::EventBuilder : public Internal<EventBuilder> {
public:
    EventBuilder();

    /// Convenience constructor for creating an event hit. Additional fields
    /// can be specified using the setter methods.
    /// @param category in which the event will be filed. Example: "Video"
    /// @param action Action associated with the event. Example: "Play"
    explicit EventBuilder(const std::string& category,
                          const std::string& action);

    EventBuilder& setCategory(const std::string& category);
    EventBuilder& setAction(const std::string& action);
    EventBuilder& setLabel(const std::string& label);
    EventBuilder& setValue(int value);
};

class GoogleProtocolAnalytics : public cocos2d::plugin::ProtocolAnalytics {
public:
    GoogleProtocolAnalytics();
    virtual ~GoogleProtocolAnalytics();

    void configureTracker(const std::string& trackerId);
    void createTracker(const std::string& trackerId);
    void enableTracker(const std::string& trackerId);

    void setLogLevel(GALogLevel logLevel);

    void dispatchHits();

    void dispatchPeriodically(int seconds);

    void stopPeriodicalDispatch();

    /// Use HitBuilders::ScreenViewBuilder.
    CC_DEPRECATED_ATTRIBUTE
    void trackScreen(const std::string& screenName);

    /// Use HitBuilders::EventBuilder.
    CC_DEPRECATED_ATTRIBUTE
    void trackEvent(const std::string& category, const std::string& action,
                    const std::string& label, int value);

    /// Use HitBuilders::TimingBuilder.
    CC_DEPRECATED_ATTRIBUTE
    void trackTiming(const std::string& category, int interval,
                     const std::string& name, const std::string& label);

    /// Use HitBuilders::ExceptionBuilder.
    CC_DEPRECATED_ATTRIBUTE
    void trackException(const std::string& description, bool isFatal);

    void trackEcommerceTransactions(const std::string& identity,
                                    const std::string& productName,
                                    const std::string& productCategory,
                                    float priceValue);

    /// Use HitBuilders::SocialBuilder.
    CC_DEPRECATED_ATTRIBUTE
    void trackSocial(const std::string& network, const std::string& action,
                     const std::string& target);

    void setDryRun(bool isDryRun);

    void enableAdvertisingTracking(bool enable);

    /// Sets the model value for the given key. All subsequent track or send
    /// calls will send this key-value pair along as well. To remove a
    /// particular field, simply set the value to null.
    /// @param key The key of the field that needs to be set. It starts with "&"
    /// followed by the parameter name. The complete list of fields can be found
    /// at https://goo.gl/M6dK2U.
    /// @param value A string value to be sent to Google servers. A null value
    /// denotes that the value should not be sent over wire.
    void setParameter(const std::string& key, const std::string& value);

    /// Set the screen name to be associated with all subsequent hits.
    void setScreenName(const std::string& screenName);

    /// Merges the model values set on this Tracker via send(Map) with params
    /// and generates a hit to be sent. The hit may not be dispatched
    /// immediately. Note that the hit type must set for the hit to be
    /// considered valid. More information on this can be found at
    /// https://goo.gl/HVIXHR.
    void sendHit(const std::map<std::string, std::string>& parameters);
};
NS_SENSPARK_PLUGIN_ANALYTICS_END

#endif
