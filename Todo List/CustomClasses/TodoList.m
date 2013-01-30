//
//  TodoList.m
//  Todo List
//
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "TodoList.h"

@implementation TodoList

- (BOOL) isEqual:(id)object {
    TodoList *otherObject = (TodoList*) object;
    if (object == self) {
        return YES;
    } else if(!object || ![object isKindOfClass:[self class]]) {
        return NO;
    } else if(otherObject.objectId.longLongValue != self.objectId.longLongValue){
        return NO;
    }
    return YES;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"List name: %@, Completed at: %@", self.text, self.completedAtDate];
}
@end
