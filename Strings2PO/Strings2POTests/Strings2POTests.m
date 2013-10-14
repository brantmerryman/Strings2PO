//
//  Strings2POTests.m
//  Strings2POTests
//
//  Created by Brant Merryman on 10/11/13.
//  Copyright (c) 2013 GoldenFrog. All rights reserved.
//

#import "Strings2POTests.h"

#import "NSString+CommentAware.h"


NSString * kTestString = @" /* Class = \"NSPanel\"; title = \"Connection Log\"; ObjectID = \"5\"; */ \"5.title\" = \"Connection Log\"; /* Class = \"NSButtonCell\"; title = \"Copy To Clipboard\"; ObjectID = \"29\"; */ \"29.title\" = \"Copy To Clipboard\"; /* Class = \"NSButtonCell\"; title = \"Email To Support\"; ObjectID = \"59\"; */ \"59.title\" = \"Email To Support\";";

@implementation Strings2POTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testCommentsRanges
{
    NSArray * commentRanges = [kTestString commentsRanges];

    
    for (id rng in commentRanges) {
        NSAssert([rng isKindOfClass:[NSDictionary class]], @"Invalid type.");
        NSRange commentRange = [(NSDictionary *)rng rangeFromDictionary];
        NSLog(@"%@", [kTestString substringWithRange: commentRange]);
    }
}

- (void)testStringCommentsAware
{
    NSArray * comps = [kTestString componentsSeparatedByStringNotCommentedOut:@";"];
    
    for (id comp in comps) {
        NSLog(@"%@", [comp description]);
    }
}

@end
