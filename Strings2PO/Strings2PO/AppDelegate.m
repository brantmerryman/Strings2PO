//
//  AppDelegate.m
//  Strings2PO
//
//  Created by Brant Merryman on 10/11/13.
//  Copyright (c) 2013 GoldenFrog. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    stringFiles = [NSMutableArray arrayWithCapacity:100];
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
        NSLog(@"Process and save");
        
    }];
    
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
                    NSLog(@"%@", filePath);
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
