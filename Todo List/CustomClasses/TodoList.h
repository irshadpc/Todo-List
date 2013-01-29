//
//  TodoList.h
//  Todo List
//
//  Created by Nikhil Prasad on 28/01/13.
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

@interface TodoList : NSObject
@property (nonatomic, strong) NSNumber *objectId;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *completedAtDate;
@end
