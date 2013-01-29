//
//  DetailViewController.h
//  Todo List
//
//  Created by Nikhil Prasad on 28/01/13.
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

@class TodoList;

@interface DetailViewController : UITableViewController <UISplitViewControllerDelegate>
@property (nonatomic, strong) TodoList *todoList;
@end
