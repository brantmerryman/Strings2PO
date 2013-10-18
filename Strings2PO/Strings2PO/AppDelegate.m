//
//  AppDelegate.m
//  Strings2PO
//
//  Created by Brant Merryman on 10/11/13.
//  Copyright (c) 2013 GoldenFrog. All rights reserved.
//

#import "AppDelegate.h"
#import "NSString+CommentAware.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    stringFiles = [NSMutableArray arrayWithCapacity:100];
    
    [self addObserver:self forKeyPath:@"busy" options:0 context:nil];
    
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (IBAction)addAction:(id)sender
{
    NSOpenPanel * op = [NSOpenPanel openPanel];
    [op setCanChooseDirectories:YES];
    [op setCanChooseFiles:YES];
    
    [op setAllowsMultipleSelection:YES];
    
    [op setAllowedFileTypes:@[@"strings"]];
    
    
    [op beginSheetModalForWindow:self.window completionHandler:^(NSInteger rc){
        
        if (1 != rc) { return; }
        
         dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     
         dispatch_apply(op.URLs.count, q, ^(size_t i){
            [self processItem: [[op.URLs objectAtIndex: i] path]];
        });
     
        dispatch_async(dispatch_get_main_queue(), ^{
            [stringsFilesTable reloadData];
        });
        
    }];
    
    
}


- (IBAction)removeAction:(id)sender
{
    
    @synchronized (stringFiles) {
        [stringFiles removeObjectsAtIndexes:stringsFilesTable.selectedRowIndexes];
    }
    
    [stringsFilesTable reloadData];
    removeButton.enabled = NO;
}


- (IBAction)generatePOAction:(id)sender
{
    
    NSSavePanel * sp = [NSSavePanel savePanel];
    
    [sp setCanCreateDirectories: YES];
    [sp setAllowedFileTypes:@[@"po"]];
    [sp setAllowsOtherFileTypes:NO];
    [sp setExtensionHidden: NO];
    
    
    [sp beginSheetModalForWindow:self.window completionHandler:^(NSInteger rc){
    
        if (1 != rc) { return; }
        
        // process and save
        
        
        [NSThread detachNewThreadSelector:@selector(generatePO:) toTarget:self withObject:sp.URL];
        
    }];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"busy"]) {
        if (self.busy) {
            [progressIndicator startAnimation:nil];
        } else {
            [progressIndicator stopAnimation:nil];
        }
    }
}

- (void)generatePO:(id)context
{
    @autoreleasepool {
        self.busy = YES;
        
        if (![context isKindOfClass:[NSURL class]]) {
            NSLog(@"Error: destination URL not specified.");
            return;
        }
        
        NSMutableDictionary * encodings = [[NSMutableDictionary alloc] initWithCapacity:stringFiles.count];
        
        NSMutableArray * ma = [NSMutableArray arrayWithCapacity:5000];
        
        NSUInteger neededCapacity = 0;
        
        for (NSString * filePath in stringFiles) {
            
            NSError * err = nil;
            NSStringEncoding theEncoding;
            NSString * contents = [NSString stringWithContentsOfFile:filePath usedEncoding:&theEncoding error:&err];
            if (err) {
                NSLog(@"%@", [err description]);
                continue;
            }
            
            neededCapacity += contents.length;
            
            NSNumber * nEncoding = [NSNumber numberWithUnsignedInteger:theEncoding];
            
            NSNumber * count = [encodings objectForKey:nEncoding];
            if (![count isKindOfClass:[NSNumber class]]) {
                count = @0;
            }
            
            [encodings setObject:[NSNumber numberWithUnsignedInteger:[count unsignedIntegerValue] + 1 ] forKey:nEncoding];

            
            // process a file.
            NSArray * stringRecords = [contents componentsSeparatedByStringNotCommentedOut:@";"];
            
            for (NSString * record in stringRecords) {
                NSString * rec2 = [record copy];
                // now break it into three things: context, key, and value.
                
                // get context
                NSString * context = @"";
                NSRange r2 = NSMakeRange(0, 0);
                NSRange r1 = [rec2 rangeOfString:@"/*"];
                if (NSNotFound != r1.location) {
                    r2 = [rec2 rangeOfString:@"*/"];
                    if (NSNotFound != r2.location) {
                        NSRange contextRange = NSMakeRange(r1.location + r1.length, r2.location - (r1.location + r1.length));
                        context = [rec2 substringWithRange:contextRange];
                    }
                }
                
                // get key
                NSMutableString * key = [NSMutableString stringWithCapacity:rec2.length];
                BOOL outside = YES;
                BOOL ignoreQuote = NO;
                NSUInteger i = r2.location + r2.length;
                for (; i < rec2.length; ++i) {
                    switch ([rec2 characterAtIndex:i]) {
                        case '\\':
                            ignoreQuote = YES;
                            [key appendString:[rec2 substringWithRange:NSMakeRange(i, 1)]];
                            break;
                        case '\"':
                            if (!ignoreQuote) {
                                if (outside) {
                                    outside = NO;
                                    // start looking for key.
                                } else {
                                     // key done.
                                    rec2 = [rec2 substringFromIndex:i+1];
                                    i = rec2.length;
                                }
                                break;
                            } else {
                                ignoreQuote = NO;
                            }
                        default:
                            if (!outside) {
                                [key appendString:[rec2 substringWithRange:NSMakeRange(i, 1)]];
                            }
                            break;
                            
                    }
                }
                
                
                
                // get value
                NSMutableString * value = [NSMutableString stringWithCapacity:rec2.length];
                ignoreQuote = NO;
                outside = YES;
                for (i = 0; i < rec2.length; ++i) {
                    switch ([rec2 characterAtIndex:i]) {
                        case '\\':
                            ignoreQuote = YES;
                            [value appendString:[rec2 substringWithRange:NSMakeRange(i, 1)]];
                            break;
                        case '\"':
                            if (!ignoreQuote) {
                                if (outside) {
                                    outside = NO;
                                    // start looking for key.
                                } else {
                                    // key done.
                                    i = rec2.length;
                                }
                                break;
                            } else {
                                ignoreQuote = NO;
                            }
                        default:
                            if (!outside) {
                                [value appendString:[rec2 substringWithRange:NSMakeRange(i, 1)]];
                            }
                            
                            break;
                            
                    }
                }
                
                

             
                [ma addObject:@{ @"context" : context, @"key" : key, @"value" : value }];
            }
            

        }
        
        
        
        if (ma.count > 0) {
        
            NSMutableString * outputString = [NSMutableString stringWithCapacity:neededCapacity];
            
            // now output the PO file.
            
            NSDateFormatter * df = [[NSDateFormatter alloc] init];
            [df setDateStyle:NSDateFormatterMediumStyle];
            [df setTimeStyle:NSDateFormatterMediumStyle];
            
            [outputString appendFormat:@"# File created %@\n\n", [df stringFromDate:[NSDate date]]];
            
            NSMutableSet * preventDuplicates = [[NSMutableSet alloc] initWithCapacity:ma.count];

            for (NSDictionary * dict in ma) {
                NSString * context = [dict objectForKey:@"context"];
                NSString * key = [dict objectForKey:@"key"];
                NSString * value = [dict objectForKey:@"value"];
                
                if ([preventDuplicates containsObject:value])
                    continue;
                
                [preventDuplicates addObject:value];
                
                [outputString appendFormat:@"# Context %@\n", context];
                [outputString appendFormat:@"# %@\n", key];
                
                [outputString appendFormat:@"msgid \"%@\"\n", value];
                [outputString appendFormat:@"msgstr \"%@\"\n\n", @""];
            }
            
            NSError * err = nil;
            if (![outputString writeToURL:(NSURL *)context atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
                NSLog(@"Failed to write file.");
            }
            if (err) {
                NSLog(@"%@", [err description]);
            }
        }
        
        self.busy = NO;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return stringFiles.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return @{ @"filePath" : [stringFiles objectAtIndex:row] };
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSIndexSet * indexSet = stringsFilesTable.selectedRowIndexes;
    
    removeButton.enabled = (0 != indexSet.count);
    
}

- (void)processItem:(NSString *)filePath
{
    BOOL directory;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&directory]) {
        
        if (directory) {
            
            NSError * err = nil;
            NSArray * contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:&err];
            if (err) {
                NSLog(@"Error: %@ at %s(%d)", [err description], __FILE__, __LINE__);
            } else {
                
                dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                
                dispatch_apply(contents.count, q, ^(size_t i){
                    [self processItem: [filePath stringByAppendingPathComponent: [contents objectAtIndex: i]]];
                });

                
            }
            
            
        } else {
            if ([filePath hasSuffix:@".strings"]) {
            
                // add it to the list.
                @synchronized (stringFiles) {
                    [stringFiles addObject: filePath];
                }
            }
        }
        
        
    } else {
        // its not there??
        NSLog(@"File not found: %@", filePath);
    }
    
    
}

@end
