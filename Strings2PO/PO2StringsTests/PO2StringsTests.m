//
//  PO2StringsTests.m
//  PO2StringsTests
//
//  Created by Brant Merryman on 10/18/13.
//  Copyright (c) 2013 GoldenFrog. All rights reserved.
//

#import "PO2StringsTests.h"
#import "NSDictionary+poFile.h"

@implementation PO2StringsTests

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

- (void)testConvertPO2Dict
{
    NSDictionary * d = [NSDictionary dictionaryWithContentsOfPOFile: @"/Users/brantm/strings2po/Strings2PO/PO2StringsTests/fr-vypr-mac-2.0.po"];
    NSLog(@"%@", [d description]);
    
}

@end
