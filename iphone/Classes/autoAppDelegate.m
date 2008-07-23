//
//  autoAppDelegate.m
//  auto
//
//  Created by Matthew Campbell on 7/23/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "autoAppDelegate.h"
#import "RootViewController.h"

// Private interface for AppDelegate - internal only methods.
@interface autoAppDelegate (Private)
- (void)initializeDatabase;
@end


@implementation autoAppDelegate

@synthesize window;
@synthesize navigationController;


- (id)init {
	if (self = [super init]) {
		// 
	}
	return self;
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"auto.db"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"auto.db"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

// Open the database connection and retrieve minimal information for all objects.
- (void)initializeDatabase {
    NSMutableArray *bookArray = [[NSMutableArray alloc] init];
    //self.books = bookArray;
    [bookArray release];
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"auto.db"];
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"auto.sql"];
	int ret = 0;
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        // Get the primary key for  books.
        const char *sql = "SELECT * FROM epa2";
        sqlite3_stmt *statement;
        // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
        // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
        ret = sqlite3_prepare_v2(database, sql, -1, &statement, NULL) ;
		if (ret == SQLITE_OK) {
            // We "step" through the results - once for each row.
            while (sqlite3_step(statement) == SQLITE_ROW) {
                // The second parameter indicates the column index into the result set.
                int primaryKey = sqlite3_column_int(statement, 2);
                // We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
                // autorelease is slightly more expensive than release. This design choice has nothing to do with
                // actual memory management - at the end of this block of code, all the book objects allocated
                // here will be in memory regardless of whether we use autorelease or release, because they are
                // retained by the books array.
				NSLog(@"value-%d", primaryKey);
				
				
				const char *c = (const char *)sqlite3_column_text(statement, 0);
				
				// check for a null row
				if (c) {
					NSString *s = [NSString stringWithUTF8String:c];
					NSLog(s);
				}
					
               // Book *book = [[Book alloc] initWithPrimaryKey:primaryKey database:database];
              //  [books addObject:book];
           //     [book release];
            }
        }
        // "Finalize" the statement - releases the resources associated with the statement.
        sqlite3_finalize(statement);
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	NSLog(@"========START============");
	[self initializeDatabase];
	NSLog(@"=========DONE============");

	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
    // Close the database.
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }	
	NSLog(@"Closed the database.");
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
