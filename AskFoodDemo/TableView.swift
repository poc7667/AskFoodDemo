//
//  TableView.swift
//  Ask Food
//
//  Created by Colearo on 16/1/26.
//  Copyright © 2016年 Colearo. All rights reserved.
//

import UIKit

enum ChatBubbleTypingType
{
    case Nobody
    case Me
    case Somebody
}

class TableView:UITableView,UITableViewDelegate, UITableViewDataSource
{
    
    var bubbleSection:NSMutableArray!
    var chatDataSource:ChatDataSource!
    
    var  snapInterval:NSTimeInterval!
    var  typingBubble:ChatBubbleTypingType!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        //the snap interval in seconds implements a headerview to seperate chats
        self.snapInterval = 60 * 60 * 24; //one day
        self.typingBubble = ChatBubbleTypingType.Nobody
        self.bubbleSection = NSMutableArray()
        
        super.init(frame:frame, style:style)
        
        self.backgroundColor = UIColor.clearColor()
        
        self.separatorStyle = UITableViewCellSeparatorStyle.None
        self.delegate = self
        self.dataSource = self
    }
    
    //按日期排序方法
    func sortDate(m1: AnyObject!, m2: AnyObject!) -> NSComparisonResult {
        if((m1 as! MessageItem).date.timeIntervalSince1970 < (m2 as! MessageItem).date.timeIntervalSince1970)
        {
            return NSComparisonResult.OrderedAscending
        }
        else
        {
            return NSComparisonResult.OrderedDescending
        }
    }
    
    override func reloadData()
    {
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.bubbleSection = NSMutableArray()
        var count =  0
        if ((self.chatDataSource != nil))
        {
            count = self.chatDataSource.rowsForChatTable(self)
            
            if(count > 0)
            {
                let bubbleData =  NSMutableArray(capacity:count)
                
                for (var i = 0; i < count; i++)
                {
                    let object =  self.chatDataSource.chatTableView(self, dataForRow:i)
                    bubbleData.addObject(object)
                }
                bubbleData.sortUsingComparator(sortDate)
                
                var last =  ""
                
                var currentSection = NSMutableArray()
                // 创建一个日期格式器
                let dformatter = NSDateFormatter()
                // 为日期格式器设置格式字符串
                dformatter.dateFormat = "dd"
                
                for (var i = 0; i < count; i++)
                {
                    let data =  bubbleData[i] as! MessageItem
                    // 使用日期格式器格式化日期，日期不同，就新分组
                    let datestr = dformatter.stringFromDate(data.date)
                    if (datestr != last)
                    {
                        currentSection = NSMutableArray()
                        self.bubbleSection.addObject(currentSection)
                    }
                    self.bubbleSection[self.bubbleSection.count-1].addObject(data)
                    
                    last = datestr
                }
            }
        }
        super.reloadData()
        
        //滑向最后一部分
        let secno = self.bubbleSection.count - 1
        let indexPath =  NSIndexPath(forRow:self.bubbleSection[secno].count,inSection:secno)
        self.scrollToRowAtIndexPath(indexPath,atScrollPosition:UITableViewScrollPosition.Bottom,animated:true)
    }
    
    func numberOfSectionsInTableView(tableView:UITableView)->Int
    {
        var result = self.bubbleSection.count
        if (self.typingBubble != ChatBubbleTypingType.Nobody)
        {
            result++;
        }
        return result;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if (section >= self.bubbleSection.count)
        {
            return 1
        }
        
        return self.bubbleSection[section].count+1
    }
    
    func tableView(tableView:UITableView,heightForRowAtIndexPath  indexPath:NSIndexPath) -> CGFloat
    {
        // Header
        if (indexPath.row == 0)
        {
            return TableHeaderViewCell.getHeight()
        }
        let section : AnyObject  =  self.bubbleSection[indexPath.section]
        let data = section[indexPath.row - 1]
        
        let item =  data as! MessageItem
        let height  = item.insets.top + max(item.view.frame.size.height , 52) + item.insets.bottom
        print("height:\(height)")
        return height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // Header based on snapInterval
        if (indexPath.row == 0)
        {
            let cellId = "HeaderCell"
            
            let hcell =  TableHeaderViewCell(reuseIdentifier:cellId)
            let section : AnyObject  =  self.bubbleSection[indexPath.section]
            let data = section[indexPath.row] as! MessageItem
            hcell.setDate(data.date)
            return hcell
        }
        // Standard
        let cellId = "ChatCell"
        
        let section : AnyObject  =  self.bubbleSection[indexPath.section]
        let data = section[indexPath.row - 1]
        
        let cell =  TableViewCell(data:data! as! MessageItem, reuseIdentifier:cellId)
        
        return cell
    }
}