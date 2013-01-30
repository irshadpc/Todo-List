//
//  Task.h
//  Todo List
//
//  Created by Kauserali on 29/01/13.
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

@interface Task : NSObject
@property (nonatomic, strong) NSNumber *objectId;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *completedAtDate;
@end
