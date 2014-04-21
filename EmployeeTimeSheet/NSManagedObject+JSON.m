//
//  NSManagedObject+JSON.m
//  SignificantDates
//
//  Created by Ismail on 19/04/2014.
//
//

#import "NSManagedObject+JSON.h"

@implementation NSManagedObject (JSON)
- (NSDictionary *)JSONToCreateObjectOnServer {
    @throw [NSException exceptionWithName:@"JSONStringToCreateObjectOnServer Not Overridden" reason:@"Must override JSONStringToCreateObjectOnServer on NSManagedObject class" userInfo:nil];
    return nil;
}
@end
