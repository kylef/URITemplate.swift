//
//  DynamicTestCase.m
//  URITemplate
//
//  Created by Kyle Fuller on 08/09/2015.
//  Copyright © 2015 Kyle Fuller. All rights reserved.
//

#import "DynamicTestCase.h"

@implementation DynamicTestCase

+ (NSArray <NSString*>*)testSelectors {
  return @[];
}

+ (NSArray <NSInvocation *> *)testInvocations {
  NSMutableArray *testInvocations = [NSMutableArray array];
  NSArray *testSelectors = [self testSelectors];

  for (NSString *selector in testSelectors) {
    [testInvocations addObject:[[self testCaseWithSelector:NSSelectorFromString(selector)] invocation]];
  }

  return testInvocations;
}

@end
