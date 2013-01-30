//
//  DetailViewController.h
//  Todo List
//
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

@class TodoList;

@interface DetailViewController : UITableViewController <UISplitViewControllerDelegate>
@property (nonatomic, strong) TodoList *todoList;
@end
