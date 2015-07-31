//
//  ListScene.cpp
//  HelloPlugins
//
//  Created by Duc Nguyen on 7/17/15.
//
//

#include "TestSenspark.h"
#include "ListLayer.h"
#include "HelloWorldScene.h"

USING_NS_CC;
USING_NS_CC_EXT;
USING_NS_SENSPARK;

bool ListLayer::init() {
    //////////////////////////////
    // 1. super init first
    if ( !Layer::init() )
    {
        return false;
    }
    
    Size visibleSize = Director::getInstance()->getVisibleSize();
    Point origin = Director::getInstance()->getVisibleOrigin();
    Point posMid = Point(origin.x + visibleSize.width / 2, origin.y + visibleSize.height / 2);
    Point posBR = Point(origin.x + visibleSize.width, origin.y);
    Point posBL = Point(origin.x, origin.y);
    
    
    MenuItemFont *pBackItem = MenuItemFont::create("Back", CC_CALLBACK_1(ListLayer::onBackCallback, this));
    Size backSize = pBackItem->getContentSize();
    pBackItem->setPosition(posBR + Point(- backSize.width / 2, backSize.height / 2));
    
    MenuItemFont *pMenuItem = MenuItemFont::create("Menu", CC_CALLBACK_1(ListLayer::onMenuCallback, this));
    Size menuSize = pMenuItem->getContentSize();
    pMenuItem->setPosition(posBL + Point(menuSize.width / 2, menuSize.height / 2));
    
    Menu* pMenu = Menu::create(pBackItem, pMenuItem, nullptr);
    pMenu->setPosition(Point::ZERO);
    addChild(pMenu, 1);
    
    _testListView = TableView::create(this, visibleSize);
    _testListView->setDelegate(this);
    _testListView->setPosition(posBL);
    _testListView->setVerticalFillOrder(TableView::VerticalFillOrder::TOP_DOWN);
    
    addChild(_testListView);
    
    return true;
}

void ListLayer::onMenuCallback(cocos2d::Ref* pSender) {
    Director::getInstance()->replaceScene(HelloWorld::scene());
}

void ListLayer::onBackCallback(cocos2d::Ref* pSender) {
    auto runningScene = Director::getInstance()->getRunningScene();
    
    if (dynamic_cast<TestSenspark*>(runningScene->getChildByTag(MAIN_LAYER_TAG)))
        Director::getInstance()->replaceScene(HelloWorld::scene());
    else
        Director::getInstance()->popScene();
}

void ListLayer::addTest(const std::string &title, const std::function<void()> &action) {
    _actions.push_back(action);
    _titles.push_back(title);
    _testListView->reloadData();
}

#pragma mark - TableViewDataSource Interface

Size ListLayer::cellSizeForTable(TableView *table) {
    return Size(table->getViewSize().width, 40);
};

TableViewCell* ListLayer::tableCellAtIndex(TableView *table, ssize_t idx) {
    auto cell = table->dequeueCell();
    if (!cell)
    {
        cell = TableViewCell::create();
        auto label = Label::createWithTTF(_titles[idx], "fonts/Marker Felt.ttf", 25.0f);
        label->setTag(TABLE_LABEL_TAG);
        label->setPosition(table->getViewSize().width / 2, 15);
        cell->addChild(label);
    }
    else
    {
        auto label = (Label*)cell->getChildByTag(TABLE_LABEL_TAG);
        label->setString(_titles[idx]);
    }
    
    return cell;
}

ssize_t ListLayer::numberOfCellsInTableView(TableView *table) {
    return _titles.size();
}

#pragma mark - TableViewDelegate Interface

void ListLayer::tableCellTouched(TableView* table, TableViewCell* cell) {
    auto func = _actions[cell->getIdx()];
    func();
}

void ListLayer::tableCellHighlight(TableView* table, TableViewCell* cell) {
    auto label = cell->getChildByTag(TABLE_LABEL_TAG);
    label->setScale(1.1f);
}

void ListLayer::tableCellUnhighlight(TableView* table, TableViewCell* cell) {
    auto label = cell->getChildByTag(TABLE_LABEL_TAG);
    label->setScale(1.f);
}