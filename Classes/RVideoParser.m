//
//  RVideoParser.m
//  RVideoURLParser
//
//  Created by Robin Qu on 13-6-28.
//  Copyright (c) 2013年 Robin Qu. All rights reserved.
//

#import "RVideoParser.h"
#import "RYoukuStrategy.h"
#import "RTudouStrategy.h"
#import "RSohuStrategy.h"
#import "RVideoURLParserCommon.h"

@interface RVideoParser ()

@property (nonatomic, retain) NSMutableSet *strategies;

@end

@implementation RVideoParser

+ (id)sharedVideoParser
{
    static RVideoParser *parser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSSet *set = [NSSet setWithObjects:[RYoukuStrategy class], [RTudouStrategy class], [RSohuStrategy class], nil];
        parser = [[RVideoParser alloc] initWithStrategies:set];
    });
    return parser;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.strategies = [NSMutableSet set];
    }
    return self;
}

- (id)initWithStrategies:(NSSet *)strategies
{
    self = [self init];
    if (self) {
        [self.strategies setSet:strategies];
    }
    return self;
}

- (void)addStrategy:(RVideoParserStrategy*)strategy
{
    [self.strategies addObject:strategy];
}

- (RVideoParserStrategy*)findStrategyForURL:(NSURL *)url
{
    __block RVideoParserStrategy *strategy = nil;
    [self.strategies enumerateObjectsUsingBlock:^(Class StrategyClass, BOOL *stop) {
        BOOL canHandle = [StrategyClass canHandleURL:url];
        if (canHandle) {
            strategy = [StrategyClass sharedInstance];
            *stop = YES;
        }
    }];
    return strategy;
}

- (void)parseWithURL:(NSURL *)url callback:(VideoParserCallback)callback
{
    RVideoParserStrategy* strategy = [self findStrategyForURL:url];
    if (strategy) {
        [strategy parseURL:url withCallback:callback];
    } else {
        if (callback) {
            callback([NSError errorWithDomain:kDefaultErrorDomain code:kVideoParserParsingErrorCode userInfo:nil], nil);
        }
    }
}

@end
