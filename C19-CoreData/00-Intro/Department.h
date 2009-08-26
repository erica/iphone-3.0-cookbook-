//
//  Department.h
//  HelloWorld
//
//  Created by Erica Sadun on 8/25/09.
//  Copyright 2009 Up To No Good, Inc.. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Department :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * groupName;
@property (nonatomic, retain) NSManagedObject * manager;
@property (nonatomic, retain) NSSet* members;

@end


@interface Department (CoreDataGeneratedAccessors)
- (void)addMembersObject:(NSManagedObject *)value;
- (void)removeMembersObject:(NSManagedObject *)value;
- (void)addMembers:(NSSet *)value;
- (void)removeMembers:(NSSet *)value;

@end

