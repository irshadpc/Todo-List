//
//  TodoList.m
//  Todo List
//
//  Created by Nikhil Prasad on 28/01/13.
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "TodoList.h"

@implementation TodoList

- (NSString*) description {
    return [NSString stringWithFormat:@"List name: %@, Completed at: %@", self.text, self.completedAtDate];
}
@end
