//
//  NSDictionary+poFile.h
//  Strings2PO
//
//  Created by Brant Merryman on 10/21/13.
//  Copyright (c) 2013 GoldenFrog. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (poFile)

+ (NSDictionary *)dictionaryWithContentsOfPOFile:(NSString *)filePath;

@end
