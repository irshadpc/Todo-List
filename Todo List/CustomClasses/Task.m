//
//  Task.m
//  Todo List
//
//  Created by Kauserali on 29/01/13.
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "Task.h"

@implementation Task

- (BOOL) isEqual:(id)object {
    Task *otherObject = (Task*) object;
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
    return [NSString stringWithFormat:@"Task name: %@, Completed at: %@", self.text, self.completedAtDate];
}
@end
