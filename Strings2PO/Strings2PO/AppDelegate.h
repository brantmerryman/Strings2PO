//
//  AppDelegate.h
//  Strings2PO
//
//  Created by Brant Merryman on 10/11/13.
//  Copyright (c) 2013 GoldenFrog. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate> {


    IBOutlet NSButton * addButton;
    IBOutlet NSButton * removeButton;
    IBOutlet NSButton * generatePOButton;
    
    NSMutableArray * stringFiles;
 
    IBOutlet NSTableView * stringsFilesTable;
    
}

- (IBAction)addAction:(id)sender;
- (IBAction)removeAction:(id)sender;
- (IBAction)generatePOAction:(id)sender;
- (void)processItem:(NSString *)fileFullPath;

@property (assign) IBOutlet NSWindow *window;

@end
