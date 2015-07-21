//
//  ListScene.h
//  HelloPlugins
//
//  Created by Duc Nguyen on 7/17/15.
//
//

#ifndef __HelloPlugins__ListScene__
#define __HelloPlugins__ListScene__

#include <stdio.h>
#include "cocos2d.h"
#include "extensions/cocos-ext.h"

using namespace std;
USING_NS_CC;
USING_NS_CC_EXT;

namespace senspark {

#define MAIN_LAYER_TAG      0x10
#define TABLE_LABEL_TAG     0x20
    
class ListLayer : public Layer, public TableViewDataSource, public TableViewDelegate
{
public:
    virtual bool init();
    
    //interface of TableViewDataSource
    virtual Size cellSizeForTable(TableView *table);
    virtual TableViewCell* tableCellAtIndex(TableView *table, ssize_t idx);
    virtual ssize_t numberOfCellsInTableView(TableView *table);
    
    //interface of TableViewDelegate
    virtual void tableCellTouched(TableView* table, TableViewCell* cell);
    virtual void tableCellHighlight(TableView* table, TableViewCell* cell);
    virtual void tableCellUnhighlight(TableView* table, TableViewCell* cell);
    
    void onMenuCallback(Ref* pSender);
    void onBackCallback(Ref* pSender);
    
    void addTest(const std::string& title, cocos2d::Scene* scene);
    
    CREATE_FUNC(ListLayer);
    
protected:
    vector<string>  _titles;
    Vector<Scene*>  _testScenes;
    TableView*      _testListView;
};

}
#endif /* defined(__HelloPlugins__ListScene__) */
