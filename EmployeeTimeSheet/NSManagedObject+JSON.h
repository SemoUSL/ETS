//
//  NSManagedObject+JSON.h
//  SignificantDates
//
//  Created by Ismail on 19/04/2014.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (JSON)
- (NSDictionary *)JSONToCreateObjectOnServer;
//- (NSString *)dateStringForAPIUsingDate:(NSDate *)date;
@end
