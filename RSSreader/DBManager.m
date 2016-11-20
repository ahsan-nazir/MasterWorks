//
//  DBManager.m
//  StepOne
//
//  Created by adnan on 22/02/2016.
//  Copyright © 2016 Limitless. All rights reserved.
//

#import "DBManager.h"

static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation DBManager

+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

+ (void)resetSharedInstance {
    sharedInstance = nil;
    database = nil;
    statement = nil;
}

-(BOOL)createDB
{
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent: @"StepOneDB.db"]];
    
    NSLog(@"db path = %@",databasePath);
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO) {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            char *errMsg;
            
            const char *sql_stmt =
            
            "create table if not exists tbl_Login (username text, pwd text);"
            "create table if not exists tbl_RSSFeeds (title text, description text,imgURL text, link text);"

            "create table if not exists tbl_Digest (Digest_ID text, cover_image text, NoOfPages text);"
            
            "create table if not exists tbl_NearbyPlaces(ID INTEGER PRIMARY KEY AUTOINCREMENT,PlaceName text, PlaceID Text, PlacePhone Text, PlaceAddress Text,PlaceDistance Text, PlaceLat Text , Placelng Text,PlaceIcon Text,description Text,opening_days Text,opening_time Text,website Text);"
            
            "create table if not exists tbl_CheckInPlaces(ID INTEGER PRIMARY KEY AUTOINCREMENT,PlaceID TEXT,PlaceName text,PlacePhone Text,PlaceAddress Text, PlaceCity Text,PlaceDistance Text, PlaceLat Text , Placelng Text,PlaceIcon Text,Date Text,CurrentStatus Text);"
            
            "create table if not exists tbl_CheckInTimeInOut(ID INTEGER PRIMARY KEY AUTOINCREMENT,CheckInTime Text,CheckOutTime Text, CheckInPlaceID Text);"
            
            "create table if not exists tbl_FBUserDetail(facebook_id text, name Text, email Text, gender Text, dob Text, photo Text, about_me Text, school Text, job Text, employer Text, interest text, mobile text, gcm_id Text, InstagramId text, FBRelationship Text, birthDay Text,Hometown text,Location text);"
            
            "create table if not exists tbl_StepOnOff(ID INTEGER PRIMARY KEY   AUTOINCREMENT,PlaceID TEXT,PlaceName text,PlacePhone Text,PlaceAddress Text, PlaceLat Text , Placelng Text,Distance Text,PlaceIcon Text,CurrentStatus Text,Date Text);"
            
            "create table if not exists tbl_StepOneChatFriendList(ID INTEGER PRIMARY KEY   AUTOINCREMENT,block_status TEXT,chat_status text,curTime Text,date Text, facebook_id Text , gcm_id Text,match_status Text,msg Text,msg_cnt Text, mute_status Text,my_block_status Text,name Text,new_msg_cnt Text, type Text, openchat_status Text);"
            
            "create table if not exists tbl_UnreadChatMessages(facebook_id TEXT,unread_count TEXT);"
            
            "create table if not exists tbl_OnlineStatus(facebook_id TEXT,status TEXT,dateTime TEXT);"
            
            "create table if not exists tbl_GalleryImages(ID INTEGER PRIMARY KEY AUTOINCREMENT,filename TEXT,venue_name TEXT,venue_id TEXT,photo_taken Text);"

            "create table if not exists tbl_StepOneChatRoomList(chat_key TEXT,chat_status text,curTime Text,id Text, is_deleted Text, msg Text, imageAttachment Text, received_datetime Text,receiver_id Text,sender_id Text, sent_datetime Text,show_message Text,type Text, unique_msg_id Text, friend_id Text);";
            
//            (chat_key,chat_status,curTime, id,is_deleted,msg,received_datetime,receiver_id,sender_id,sent_datetime,show_message,type,unique)
            
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_finalize(statement);
            sqlite3_close(database);
            
            
            return  isSuccess;
        }
        else
        {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}

#pragma mark
#pragma mark Settings Database actions

- (BOOL)saveDataInLoginTable
{
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into tbl_Login (username,pwd) values ('admin@admin.com','asdf1234')"];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Success");
            
            sqlite3_finalize(statement);
            sqlite3_close(database);
            
            return YES;
            
        }
        else {
            NSLog(@"failed to insert");
            
            return NO;
            
        }
    }
    return NO;
}


- (BOOL)saveDataInRSSFeedsTable
{
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:@"insert into tbl_RSSFeeds (title,description,imgURL,link) values ('admin@admin.com','asdf1234')"];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Success");
            
            sqlite3_finalize(statement);
            sqlite3_close(database);
            
            return YES;
            
        }
        else {
            NSLog(@"failed to insert");
            
            return NO;
            
        }
    }
    return NO;
}


- (BOOL)saveAllRSSFeeds:(NSArray *)arrRSSFeeds{

    //const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        char* errorMessage;
        sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
        for (NSDictionary *dict in arrRSSFeeds) {

            NSString *strTitle = [dict objectForKey:@"title"];
            NSString *stsDescription = [dict objectForKey:@"description"];
            NSString *strImgURL = [dict objectForKey:@"link"];
            NSString *strLink = [dict objectForKey:@"link"];

            strTitle = [strTitle stringByReplacingOccurrencesOfString:@"\""
                                                 withString:@""];
            strTitle = [strTitle stringByReplacingOccurrencesOfString:@"\'"
                                                           withString:@""];

            stsDescription = [stsDescription stringByReplacingOccurrencesOfString:@"\""
                                                           withString:@""];
            stsDescription = [stsDescription stringByReplacingOccurrencesOfString:@"\'"
                                                           withString:@""];
            strImgURL = [strImgURL stringByReplacingOccurrencesOfString:@"\""
                                                           withString:@""];
            strImgURL = [strImgURL stringByReplacingOccurrencesOfString:@"\'"
                                                           withString:@""];
            strLink = [strLink stringByReplacingOccurrencesOfString:@"\""
                                                           withString:@""];
            strLink = [strLink stringByReplacingOccurrencesOfString:@"\'"
                                                           withString:@""];

            
           
//            "create table if not exists tbl_RSSFeeds (mytitle text, mydescription text,myimgURL text, mylink text);"

        NSString *insertSQL = [NSString stringWithFormat:@"insert into tbl_RSSFeeds (title,description,imgURL,link) values ('%@','%@','%@','%@')",strTitle,stsDescription,strImgURL,strLink];

//        NSString *insertSQL = [NSString stringWithFormat:@"insert into tbl_RSSFeeds (title,description,imgURL,link) values ('%@','%@','%@','%@')",@"a",@"b",@"d",@"e"];

//            NSString *insertSQL = [NSString stringWithFormat:@"insert into tbl_UnreadChatMessages (facebook_id,unread_count) values ('%@','%@')",[dict objectForKey:@"facebook_id"],[dict objectForKey:@"unread_count"]];
            
            if (sqlite3_exec(database, [insertSQL UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
            {
                NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
                return NO;
            }
        }
        sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
    }

    return YES;

}

- (NSMutableArray*)getAllRSSFeeds
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    // Setup the database object
    sqlite3 *database;
    // Open the database from the users filessytem
    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        NSString *sqlStatement_userInfo =[NSString stringWithFormat:@"Select * from tbl_RSSFeeds"];
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, [sqlStatement_userInfo UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
            {
                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
                NSString *title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
                NSString *description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                NSString *imgURL = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                NSString *link = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
                
                [dataDictionary setObject:[NSString stringWithFormat:@"%@",title] forKey:@"title"];
                [dataDictionary setObject:[NSString stringWithFormat:@"%@",description] forKey:@"description"];
                [dataDictionary setObject:[NSString stringWithFormat:@"%@",imgURL] forKey:@"imgURL"];
                [dataDictionary setObject:[NSString stringWithFormat:@"%@",link] forKey:@"link"];
                [array addObject:dataDictionary];
            }
            sqlite3_finalize(compiledStatement);
        }
        else
        {
            NSLog(@"No Data Found");
        }
        // Release the compiled statement from memory
    }

    // sqlite3_close(database);

    return array;
}



//
//- (BOOL)saveSettingsFromServer:(NSArray *)arrRSSFeeds{
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
//
//        
//    NSString *insertSQL = [NSString stringWithFormat:@"insert into tbl_RSSFeeds (title,description,imgURL,link) values ('%@','%@','%@','%@')",];
//
//        
//    NSString *insertSQL = [NSString stringWithFormat:@"insert into tbl_Settings (Men,Women,MenAndWomen, LowerAgeRange,UpperAgeRange,OpenChat,AutoCheckIn,VisibleOutsideVenue,ShowVisible,SteppersAttending,ShowAge,ShowHomeTown,ShowFacebookInterests,ShowInstagramID,ShowInstagramPhotos,ShowMobileContact,ShowEmailContact,ShowEmployer,ShowJob,ShowSchool,NewMatch,Chats,showPlaces) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",[self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_men"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_women"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_men_women"]]], [NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_age_min"]], [NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_age_max"]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_openchat"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_autocheck"]]],[self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"visible_outside_venue"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_visible"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", @"1"]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_show_age"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_hometown"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_fb_interests"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_instagram_id"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_instagram_photos"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_mobile"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_email"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_employer"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_job"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_school"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_notf_newmatch"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_notf_chat"]]],[self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"show_places"]]]];
//
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE) {
//            NSLog(@"Success");
//            sqlite3_finalize(statement);
//            sqlite3_close(database);
//            return YES;
//        }
//        else {
//            NSLog(@"failed to insert");
//            return NO;
//        }
//    }
//    return NO;
//}



//
//- (BOOL)saveSettingsFromServer:(NSArray *)arrSettings {
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
//        
//    NSString *insertSQL = [NSString stringWithFormat:@"insert into tbl_Settings (Men,Women,MenAndWomen, LowerAgeRange,UpperAgeRange,OpenChat,AutoCheckIn,VisibleOutsideVenue,ShowVisible,SteppersAttending,ShowAge,ShowHomeTown,ShowFacebookInterests,ShowInstagramID,ShowInstagramPhotos,ShowMobileContact,ShowEmailContact,ShowEmployer,ShowJob,ShowSchool,NewMatch,Chats,showPlaces) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",[self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_men"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_women"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_men_women"]]], [NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_age_min"]], [NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_age_max"]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_openchat"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_autocheck"]]],[self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"visible_outside_venue"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_visible"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", @"1"]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_show_age"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_hometown"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_fb_interests"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_instagram_id"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_instagram_photos"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_mobile"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_email"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_employer"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_job"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_school"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_notf_newmatch"]]], [self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"settings_notf_chat"]]],[self getTrueFalseByValue:[NSString stringWithFormat:@"%@", [arrSettings valueForKey:@"show_places"]]]];
//        
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE) {
//            NSLog(@"Success");
//            sqlite3_finalize(statement);
//            sqlite3_close(database);
//            return YES;
//        }
//        else {
//            NSLog(@"failed to insert");
//            return NO;
//        }
//    }
//    return NO;
//}
//
//- (void) deleteChatFriendList{
//    
////    const char *dbpath = [databasePath UTF8String];
//    
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *insertSQL = [NSString stringWithFormat:@"delete from tbl_StepOneChatFriendList"];
//        
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE)
//        {
//            NSLog(@"delete success");
//            
//            sqlite3_finalize(statement);
//            // sqlite3_close(database);
//        }
//        else {
//            NSLog(@"failed to delete");
//        }
//    }
//}
//
//
//- (void)deleteChatRoomHistory:(NSString*)friend_id{
//    
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *insertSQL = [NSString stringWithFormat:@"delete from tbl_StepOneChatRoomList where friend_id = %@",friend_id];
//        
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE)
//        {
//            NSLog(@"delete success");
//            
//            sqlite3_finalize(statement);
//            // sqlite3_close(database);
//        }
//        else {
//            NSLog(@"failed to delete");
//        }
//    }
//}
//
//- (void)deleteChatRoomForAllUsersToGetChatLatestHistory{
//    
//    //    const char *dbpath = [databasePath UTF8String];
//    
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *insertSQL = [NSString stringWithFormat:@"delete from tbl_StepOneChatRoomList"];
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE)
//        {
//            NSLog(@"delete success");
//            sqlite3_finalize(statement);
//            // sqlite3_close(database);
//        }
//        else {
//            NSLog(@"failed to delete");
//        }
//    }
//}
//
//
//- (BOOL)saveChatFriendList:(NSArray *)arrChatFriendList {
//    
//    //const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        char* errorMessage;
//        sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
//        for (NSDictionary *dict in arrChatFriendList) {            
//        NSString *insertSQL = [NSString stringWithFormat:@"insert into tbl_StepOneChatFriendList (block_status,chat_status,curTime, date,facebook_id,gcm_id,match_status,msg,msg_cnt,mute_status,my_block_status,name,new_msg_cnt,type,openchat_status) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",[dict objectForKey:@"block_status"],[dict objectForKey:@"chat_status"],[dict objectForKey:@"curTime"],[dict objectForKey:@"date"],[dict objectForKey:@"facebook_id"],[dict objectForKey:@"gcm_id"],[dict objectForKey:@"match_status"],[dict objectForKey:@"msg"],[dict objectForKey:@"msg_cnt"],[dict objectForKey:@"mute_status"],[dict objectForKey:@"my_block_status"],[dict objectForKey:@"name"],[dict objectForKey:@"new_msg_cnt"],[dict objectForKey:@"type"],[dict objectForKey:@"openchat_status"]];
//
//            if (sqlite3_exec(database, [insertSQL UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//            {
//                NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
//                return NO;
//            }
//        }
//        sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
//    }
//    
//    NSLog(@"success dfdsf");
//    return YES;
//
//}
//
//- (NSMutableArray*)getAllChatFriendList
//{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    // Setup the database object
//    sqlite3 *database;
//    // Open the database from the users filessytem
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *sqlStatement_userInfo =[NSString stringWithFormat:@"Select * from tbl_StepOneChatFriendList"];
//        sqlite3_stmt *compiledStatement;
//        if(sqlite3_prepare_v2(database, [sqlStatement_userInfo UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
//        {
//            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
//                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
//                NSString *ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                NSString *block_status = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                NSString *chat_status = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
//                NSString *curTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
//                NSString *date = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
//                NSString *facebook_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
//                NSString *gcm_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
//                NSString *match_status = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
//                NSString *msg = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
//                NSString *msg_cnt = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)];
//                NSString *mute_status = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 10)];
//                NSString *my_block_status = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 11)];
//                NSString *name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 12)];
//                NSString *new_msg_cnt = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 13)];
//                NSString *type = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 14)];
//                NSString *openchat_status = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 15)];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",ID] forKey:@"ID"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",block_status] forKey:@"block_status"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",curTime] forKey:@"curTime"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",date] forKey:@"date"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",facebook_id] forKey:@"facebook_id"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",gcm_id] forKey:@"gcm_id"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",match_status] forKey:@"match_status"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",msg] forKey:@"msg"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",msg_cnt] forKey:@"msg_cnt"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",mute_status] forKey:@"mute_status"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",my_block_status] forKey:@"my_block_status"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",name] forKey:@"name"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",new_msg_cnt] forKey:@"new_msg_cnt"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",type] forKey:@"type"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",openchat_status] forKey:@"openchat_status"];
//                [array addObject:dataDictionary];
//            }
//            sqlite3_finalize(compiledStatement);
//        }
//        else
//        {
//            NSLog(@"No Data Found");
//        }
//        // Release the compiled statement from memory
//    }
//    
//    // sqlite3_close(database);
//    
//    return array;
//}
//
//- (void)deleteOnlineStatusList{
//    
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *deleteSQL = [NSString stringWithFormat:@"delete from tbl_OnlineStatus"];
//        const char *insert_stmt = [deleteSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE)
//        {
//            NSLog(@"delete success");
//            sqlite3_finalize(statement);
//        }
//        else {
//            NSLog(@"failed to delete");
//        }
//    }
//    
//}
//
//- (void)saveOnlineStatusList:(NSDictionary *)dictOnlineStatusList{
//    
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    // Setup the database object
//    sqlite3 *database;
//    // Open the database from the users filessytem
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *insertSQL = [NSString stringWithFormat:@"SELECT * FROM tbl_OnlineStatus where facebook_id='%@'",[dictOnlineStatusList objectForKey:@"facebook_id"]];
//        sqlite3_stmt *compiledStatement;
//        if(sqlite3_prepare_v2(database, [insertSQL UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
//        {
//            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
//                
//                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
//                NSString *facebook_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                NSString *status = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                NSString *dateTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",facebook_id] forKey:@"facebook_id"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",status] forKey:@"status"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",dateTime] forKey:@"dateTime"];
//                [array addObject:dataDictionary];
//            }
//            sqlite3_finalize(compiledStatement);
//        }
//        else
//        {
//            NSLog(@"No Data Found");
//        }
//        // Release the compiled statement from memory
//    }
//    // sqlite3_close(database);
//    
//    if ([array count]==0) {
//       [self insertOnlineStatusList:dictOnlineStatusList];
//    }else{
//        [self updateOnlineStatusList:dictOnlineStatusList];
//    }
//
//    //return array;
//}
//
//- (void) updateOnlineStatusList:(NSDictionary *)dictOnlineStatusList{
//    
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
//        NSString *insertSQL = [NSString stringWithFormat:@"UPDATE tbl_OnlineStatus SET status='%@',dateTime='%@' WHERE facebook_id='%@'",[dictOnlineStatusList objectForKey:@"status"],[dictOnlineStatusList objectForKey:@"dateTime"],[dictOnlineStatusList objectForKey:@"facebook_id"]];
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE) {
////            NSLog(@"Success update in local db");
//            sqlite3_finalize(statement);
//            sqlite3_close(database);
//        }
//        else {
//            NSLog(@"failed to insert in local db");
//        }
//    }
//}
//
//- (void)insertOnlineStatusList:(NSDictionary *)dictOnlineStatusList{
//    
//    //const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        char* errorMessage;
//        sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
//       // for (NSDictionary *dict in arrChatFriendList) {
//            NSString *insertSQL = [NSString stringWithFormat:@"insert into tbl_OnlineStatus (facebook_id,status,dateTime) values ('%@','%@','%@')",[dictOnlineStatusList objectForKey:@"facebook_id"],[dictOnlineStatusList objectForKey:@"status"],[dictOnlineStatusList objectForKey:@"dateTime"]];
//            
//            if (sqlite3_exec(database, [insertSQL UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//            {
//                NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
//                //return NO;
//            }
//       // }
//        sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
//    }
//    NSLog(@"success dfdsf");
//    //return YES;
//    
//}
//
//- (NSMutableArray*)getAllOnlineStatusList{
//    
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    // Setup the database object
//    sqlite3 *database;
//    // Open the database from the users filessytem
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *sqlStatement_userInfo =[NSString stringWithFormat:@"Select * from tbl_OnlineStatus"];
//        
//        sqlite3_stmt *compiledStatement;
//        if(sqlite3_prepare_v2(database, [sqlStatement_userInfo UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
//        {
//            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
//                
//                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
//                NSString *facebook_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                NSString *status = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                NSString *dateTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
//                
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",facebook_id] forKey:@"facebook_id"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",status] forKey:@"status"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",dateTime] forKey:@"dateTime"];
//                [array addObject:dataDictionary];
//            }
//            sqlite3_finalize(compiledStatement);
//        }
//        else
//        {
//            NSLog(@"No Data Found");
//        }
//        // Release the compiled statement from memory
//    }
//    // sqlite3_close(database);
//    return array;
//}
//
//- (NSMutableArray*)getOnlineStatusList:(NSString*)facebook_id{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    // Setup the database object
//    sqlite3 *database;
//    // Open the database from the users filessytem
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *sqlStatement_userInfo =[NSString stringWithFormat:@"Select * from tbl_OnlineStatus where facebook_id = '%@'",facebook_id];
//        
//        sqlite3_stmt *compiledStatement;
//        if(sqlite3_prepare_v2(database, [sqlStatement_userInfo UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
//        {
//            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
//                
//                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
//                NSString *facebook_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                NSString *status = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                NSString *dateTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
//                
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",facebook_id] forKey:@"facebook_id"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",status] forKey:@"status"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",dateTime] forKey:@"dateTime"];
//                [array addObject:dataDictionary];
//            }
//            sqlite3_finalize(compiledStatement);
//        }
//        else
//        {
//            NSLog(@"No Data Found");
//        }
//        // Release the compiled statement from memory
//    }
//    // sqlite3_close(database);
//    return array;
//}
//
//
//- (void)saveChatRoomList:(NSArray *)arrChatFriendList FrindList:(NSString*)FriendID{
//    
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *deleteSQL = [NSString stringWithFormat:@"delete from tbl_StepOneChatRoomList where friend_id = %@",FriendID];
//        const char *insert_stmt = [deleteSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE)
//        {
//            NSLog(@"delete success");
//            sqlite3_finalize(statement);
//            [self SaveChatRoomListAfterOldRecordDeleted:arrChatFriendList FrindList:FriendID];
//        }
//        else {
//            NSLog(@"failed to delete");
//        }
//    }
//    
//}
//
//-(void)SaveChatRoomListAfterOldRecordDeleted:(NSArray *)arrChatFriendList FrindList:(NSString*)FriendID {
//    
//    //const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        char* errorMessage;
//        sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
//        
//        for (NSDictionary *dict in arrChatFriendList) {
//            
//            NSCharacterSet *unwantedCharsSlash = [NSCharacterSet characterSetWithCharactersInString:@"\""];
//            NSString *requiredString = [[dict[@"msg"] componentsSeparatedByCharactersInSet:unwantedCharsSlash] componentsJoinedByString:@""];
//            NSCharacterSet *unwantedCharsAppostrophe = [NSCharacterSet characterSetWithCharactersInString:@"'"];
//            NSString *finalString = [[requiredString componentsSeparatedByCharactersInSet:unwantedCharsAppostrophe] componentsJoinedByString:@""];
//
//            NSString *insertSQL = [NSString stringWithFormat:@"insert into tbl_StepOneChatRoomList (chat_key,chat_status,curTime, id,is_deleted,msg,imageAttachment,received_datetime,receiver_id,sender_id,sent_datetime,show_message,type,unique_msg_id, friend_id) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",[dict objectForKey:@"chat_key"],[dict objectForKey:@"chat_status"],[dict objectForKey:@"curTime"],[dict objectForKey:@"id"],[dict objectForKey:@"is_deleted"],finalString,[dict objectForKey:@"imageAttachment"],[dict objectForKey:@"received_datetime"],[dict objectForKey:@"receiver_id"],[dict objectForKey:@"sender_id"],[dict objectForKey:@"sent_datetime"],[dict objectForKey:@"show_message"],[dict objectForKey:@"type"],[dict objectForKey:@"unique"],FriendID];
//            
//            if (sqlite3_exec(database, [insertSQL UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//            {
//                NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
////                return NO;
//            }
//        }
//        sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
//    }
//    
//    NSLog(@"success");
//    
////    return YES;
//    
//}
//
//
//- (NSMutableArray*)getAllChatRoomList:(NSString*)friend_id
//{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    // Setup the database object
//    sqlite3 *database;
//    // Open the database from the users filessytem
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *sqlStatement_userInfo =[NSString stringWithFormat:@"Select * from tbl_StepOneChatRoomList where friend_id = '%@'",friend_id];
//        sqlite3_stmt *compiledStatement;
//        if(sqlite3_prepare_v2(database, [sqlStatement_userInfo UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
//        {
//            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
//                
//                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
//                NSString *chat_key = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                NSString *chat_status = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                NSString *curTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
//                NSString *ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
//                NSString *is_deleted = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
//                NSString *msg = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
//                NSString *imageAttachment = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
//                NSString *received_datetime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
//                NSString *receiver_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
//                NSString *sender_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)];
//                NSString *sent_datetime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 10)];
//                NSString *show_message = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 11)];
//                NSString *type = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 12)];
//                NSString *unique = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 13)];
//                NSString *friend_ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 14)];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",chat_key] forKey:@"chat_key"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",chat_status] forKey:@"chat_status"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",curTime] forKey:@"curTime"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",ID] forKey:@"ID"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",is_deleted] forKey:@"is_deleted"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",msg] forKey:@"msg"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",imageAttachment] forKey:@"imageAttachment"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",received_datetime] forKey:@"received_datetime"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",receiver_id] forKey:@"receiver_id"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",sender_id] forKey:@"sender_id"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",sent_datetime] forKey:@"sent_datetime"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",show_message] forKey:@"show_message"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",type] forKey:@"type"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",unique] forKey:@"unique"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",friend_ID] forKey:@"friend_id"];
//
//                [array addObject:dataDictionary];
//            }
//            sqlite3_finalize(compiledStatement);
//        }
//        else
//        {
//            NSLog(@"No Data Found");
//        }
//        // Release the compiled statement from memory
//    }
//    // sqlite3_close(database);
//    return array;
//}
//
//- (NSMutableArray*)getAllUnreadChatMessages:(NSString*)facebook_id
//{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    // Setup the database object
//    sqlite3 *database;
//    // Open the database from the users filessytem
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *sqlStatement_userInfo =[NSString stringWithFormat:@"Select * from tbl_UnreadChatMessages where facebook_id = %@",facebook_id];
//        
//        sqlite3_stmt *compiledStatement;
//        if(sqlite3_prepare_v2(database, [sqlStatement_userInfo UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
//        {
//            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
//                
//                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
//                NSString *facebook_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                NSString *unread_count = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",facebook_id] forKey:@"facebook_id"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",unread_count] forKey:@"unread_count"];
//                [array addObject:dataDictionary];
//            }
//            sqlite3_finalize(compiledStatement);
//        }
//        else
//        {
//            NSLog(@"No Data Found");
//        }
//        // Release the compiled statement from memory
//    }
//    // sqlite3_close(database);
//    return array;
//}
//
//- (NSMutableArray*)getAllUnreadChatMessages
//{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    // Setup the database object
//    sqlite3 *database;
//    // Open the database from the users filessytem
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *sqlStatement_userInfo =[NSString stringWithFormat:@"Select * from tbl_UnreadChatMessages"];
//        sqlite3_stmt *compiledStatement;
//        if(sqlite3_prepare_v2(database, [sqlStatement_userInfo UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
//        {
//            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
//                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
//                NSString *facebook_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                NSString *unread_count = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",facebook_id] forKey:@"facebook_id"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",unread_count] forKey:@"unread_count"];
//                [array addObject:dataDictionary];
//            }
//            sqlite3_finalize(compiledStatement);
//        }
//        else
//        {
//            NSLog(@"No Data Found");
//        }
//        // Release the compiled statement from memory
//    }
//    // sqlite3_close(database);
//    return array;
//}
//
//
//- (BOOL)saveAllUnreadChatMessages:(NSArray *)arrUnreadChatMessagesList{
//    
//    //const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        char* errorMessage;
//        sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
//        for (NSDictionary *dict in arrUnreadChatMessagesList) {
//            NSString *insertSQL = [NSString stringWithFormat:@"insert into tbl_UnreadChatMessages (facebook_id,unread_count) values ('%@','%@')",[dict objectForKey:@"facebook_id"],[dict objectForKey:@"unread_count"]];
//            if (sqlite3_exec(database, [insertSQL UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//            {
//                NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
//                return NO;
//            }
//        }
//        sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
//    }
//    
//    return YES;
//    
//}
//
//- (void)deleteAlreadyReadMessages:(NSString*)facebook_id{
//    
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *deleteSQL = [NSString stringWithFormat:@"delete from tbl_UnreadChatMessages where facebook_id = %@",facebook_id];
//        const char *insert_stmt = [deleteSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE)
//        {
//            NSLog(@"delete success");
//            sqlite3_finalize(statement);
//            // sqlite3_close(database);
//        }
//        else {
//            NSLog(@"failed to delete");
//        }
//    }
//    
//}
//
//- (NSString *)getTrueFalseByValue:(NSString *)value {
//    if ([value isEqualToString:@"1"])
//        return @"true";
//    else
//        return @"false";
//}
//
//- (void)updateSettingByKey:(NSString *)key Value:(NSString *)valu {
//    
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
//        NSString *insertSQL = [NSString stringWithFormat:@"UPDATE tbl_Settings SET %@ = '%@' WHERE rowid = 1",key, valu];
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE) {
//            NSLog(@"Success update in local db");
//            sqlite3_finalize(statement);
//            sqlite3_close(database);
//        }
//        else {
//            NSLog(@"failed to insert in local db");
//        }
//    }
//    
//}
//
//- (BOOL)updateSettingsDetails:(NSMutableDictionary*)updateArray
//{
//    NSLog(@"%@",updateArray);
//    sqlite3_stmt *updateStmt;
//    const char *dbpath = [databasePath UTF8String];
//    if(sqlite3_open(dbpath, &database) == SQLITE_OK)
//    {
//        const char *sql = "update tbl_Settings Set Men = ?, Women = ?, Friendship = ? , LowerAgeRange = ? , UpperAgeRange = ? , OpenChat = ? , AutoCheckIn = ? , ShowVisible = ? , SteppersAttending = ? , ShowAge = ? , ShowHomeTown = ? , ShowFacebookInterests = ? , ShowInstagramID = ? , ShowInstagramPhotos = ?, ShowMobileContact = ?, ShowEmailContact = ?, ShowEmployer = ?, ShowJob = ?, ShowSchool = ?, NewMatch = ?, Chats = ?";
//        if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL)==SQLITE_OK)
//        {
//            sqlite3_bind_text(updateStmt, 1, [[updateArray objectForKey:@"Men"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 2, [[updateArray objectForKey:@"Women"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 3, [[updateArray objectForKey:@"Friendship"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 4, [[updateArray objectForKey:@"LowerAgeRange"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 5, [[updateArray objectForKey:@"UpperAgeRange"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 6, [[updateArray objectForKey:@"OpenChat"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 7, [[updateArray objectForKey:@"AutoCheckIn"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 8, [[updateArray objectForKey:@"ShowVisible"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 9, [[updateArray objectForKey:@"SteppersAttending"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 10, [[updateArray objectForKey:@"ShowAge"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 11, [[updateArray objectForKey:@"ShowHomeTown"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 12, [[updateArray objectForKey:@"ShowFacebookInterests"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 13, [[updateArray objectForKey:@"ShowInstagramID"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 14, [[updateArray objectForKey:@"ShowInstagramPhotos"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 15, [[updateArray objectForKey:@"ShowMobileContact"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 16, [[updateArray objectForKey:@"ShowEmailContact"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 17, [[updateArray objectForKey:@"ShowEmployer"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 18, [[updateArray objectForKey:@"ShowJob"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 19, [[updateArray objectForKey:@"ShowSchool"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 20, [[updateArray objectForKey:@"NewMatch"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 21, [[updateArray objectForKey:@"Chats"] UTF8String], -1, SQLITE_TRANSIENT);
//        }
//    }
//    
//    char* errmsg;
//    sqlite3_exec(database, "COMMIT", NULL, NULL, &errmsg);
//    
//    if(SQLITE_DONE != sqlite3_step(updateStmt)){
//        NSLog(@"Error while updating. %s", sqlite3_errmsg(database));
//    }
//    else{
//        NSLog(@"success update");
//        //[self clearClick:nil];
//    }
//    sqlite3_finalize(updateStmt);
//    return NO;
//    
//}
//
//- (NSMutableArray*)getCheckInPlaceIdAndNames
//{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    
//    // Setup the database object
//    sqlite3 *database;
//
//    // Open the database from the users filessytem
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
////        NSString *sqlStatement_userInfo =[NSString stringWithFormat:@"Select * from tbl_CheckInPlaces order by ID desc "];
////        NSString *sqlStatement_userInfo = [NSString stringWithFormat:@"select PlaceID,PlaceName from tbl_CheckInPlaces where CurrentStatus = 3"];
//        
//        //SELECT labs.* FROM labs INNER JOIN visit ON visit.id = labs.visitID AND patientID = ?
//
////        NSString *sqlStatement_userInfo = [NSString stringWithFormat:@"select PlaceID,PlaceName,CheckInTime,CheckOutTime from tbl_CheckInPlaces OUTER JOIN tbl_CheckInTimeInOut where tbl_CheckInPlaces.CurrentStatus = 3 AND tbl_CheckInPlaces.PlaceID = tbl_CheckInTimeInOut.PlaceID"];
//        
//        NSString *sqlStatement_userInfo = [NSString stringWithFormat:@"select PlaceID,PlaceName,PlaceAddress from tbl_CheckInPlaces where CurrentStatus = 3"];
//
//        sqlite3_stmt *compiledStatement;
//        
//        if(sqlite3_prepare_v2(database, [sqlStatement_userInfo UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
//        {
//            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
//                // Init the Data Dictionary
//                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
//                NSString *PlaceID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                NSString *PlaceName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                NSString *PlaceAddress = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceID] forKey:@"PlaceID"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceName] forKey:@"PlaceName"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceAddress] forKey:@"PlaceAddress"];
//                [array addObject:dataDictionary];
//                
//            }
//            
//        }
//        else
//        {
//            NSLog(@"No Data Found %s", sqlite3_errmsg(database));
//        }
//        sqlite3_busy_timeout(database, 500);
//        
//        // Release the compiled statement from memory
//        sqlite3_finalize(compiledStatement);
//        sqlite3_close(database);
//        
//    }
//    
//    return array;
//    
//}
//
//
//- (NSMutableArray*)getCheckInAndCheckOutTime
//{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    
//    // Setup the database object
//    sqlite3 *database;
//    
//    // Open the database from the users filessytem
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        //        NSString *sqlStatement_userInfo =[NSString stringWithFormat:@"Select * from tbl_CheckInPlaces order by ID desc "];
//        NSString *sqlStatement_userInfo = [NSString stringWithFormat:@"select CheckInTime,CheckOutTime,CheckInPlaceID from tbl_CheckInTimeInOut"];
//        sqlite3_stmt *compiledStatement;
//        if(sqlite3_prepare_v2(database, [sqlStatement_userInfo UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
//        {
//            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
//                // Init the Data Dictionary
//                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
//                NSString *CheckInTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                NSString *CheckOutTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                NSString *CheckInPlaceID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",CheckInTime] forKey:@"CheckInTime"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",CheckOutTime] forKey:@"CheckOutTime"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",CheckInPlaceID] forKey:@"CheckInPlaceID"];
//                [array addObject:dataDictionary];
//                
//            }
//            
//        }
//        else
//        {
//            NSLog(@"No Data Found %s", sqlite3_errmsg(database));
//        }
//        
//        sqlite3_busy_timeout(database, 500);
//        sqlite3_finalize(compiledStatement);
//        sqlite3_close(database);
//        
//    }
//    
//    return array;
//
//}
//
//- (NSMutableDictionary*)getSettingsDetails
//{
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
//    {
//        NSString *querySQL = [NSString stringWithFormat:@"select * from tbl_Settings"];
//        const char *query_stmt = [querySQL UTF8String];
//        NSMutableDictionary *resultArray = [[NSMutableDictionary alloc]init];
//        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
//        {
//            if (sqlite3_step(statement) == SQLITE_ROW)
//            {
//                NSString *Men = [[NSString alloc] initWithUTF8String:
//                                 (const char *) sqlite3_column_text(statement, 0)];
//                [resultArray setObject:Men forKey:@"Men"];
//                NSString *Women = [[NSString alloc] initWithUTF8String:
//                                   (const char *) sqlite3_column_text(statement, 1)];
//                [resultArray setObject:Women forKey:@"Women"];
//                NSString *Friendship = [[NSString alloc] initWithUTF8String:
//                                        (const char *) sqlite3_column_text(statement, 2)];
//                [resultArray setObject:Friendship forKey:@"MenAndWomen"];
//                NSString *LowerAgeRange = [[NSString alloc] initWithUTF8String:
//                                           (const char *) sqlite3_column_text(statement, 3)];
//                [resultArray setObject:LowerAgeRange forKey:@"LowerAgeRange"];
//                
//                NSString *UpperAgeRange = [[NSString alloc] initWithUTF8String:
//                                           (const char *) sqlite3_column_text(statement, 4)];
//                [resultArray setObject:UpperAgeRange forKey:@"UpperAgeRange"];
//                NSString *OpenChat = [[NSString alloc] initWithUTF8String:
//                                      (const char *) sqlite3_column_text(statement, 5)];
//                [resultArray setObject:OpenChat forKey:@"OpenChat"];
//                NSString *AutoCheckIn = [[NSString alloc] initWithUTF8String:
//                                         (const char *) sqlite3_column_text(statement, 6)];
//                [resultArray setObject:AutoCheckIn forKey:@"AutoCheckIn"];
//                NSString *VisibleOutsideVenue = [[NSString alloc] initWithUTF8String:
//                                         (const char *) sqlite3_column_text(statement, 7)];
//                [resultArray setObject:VisibleOutsideVenue forKey:@"VisibleOutsideVenue"];
//                NSString *ShowVisible = [[NSString alloc] initWithUTF8String:
//                                         (const char *) sqlite3_column_text(statement, 8)];
//                [resultArray setObject:ShowVisible forKey:@"ShowVisible"];
//                NSString *SteppersAttending = [[NSString alloc] initWithUTF8String:
//                                               (const char *) sqlite3_column_text(statement, 9)];
//                [resultArray setObject:SteppersAttending forKey:@"SteppersAttending"];
//                NSString *ShowAge = [[NSString alloc] initWithUTF8String:
//                                     (const char *) sqlite3_column_text(statement, 10)];
//                [resultArray setObject:ShowAge forKey:@"ShowAge"];
//                
//                NSString *ShowHomeTown = [[NSString alloc] initWithUTF8String:
//                                          (const char *) sqlite3_column_text(statement, 11)];
//                [resultArray setObject:ShowHomeTown forKey:@"ShowHomeTown"];
//                NSString *ShowFacebookInterests = [[NSString alloc] initWithUTF8String:
//                                                   (const char *) sqlite3_column_text(statement, 12)];
//                [resultArray setObject:ShowFacebookInterests forKey:@"ShowFacebookInterests"];
//                NSString *ShowInstagramID = [[NSString alloc] initWithUTF8String:
//                                             (const char *) sqlite3_column_text(statement, 13)];
//                [resultArray setObject:ShowInstagramID forKey:@"ShowInstagramID"];
//                NSString *ShowInstagramPhotos = [[NSString alloc] initWithUTF8String:
//                                                 (const char *) sqlite3_column_text(statement, 14)];
//                [resultArray setObject:ShowInstagramPhotos forKey:@"ShowInstagramPhotos"];
//                NSString *ShowMobileContact = [[NSString alloc] initWithUTF8String:
//                                               (const char *) sqlite3_column_text(statement, 15)];
//                [resultArray setObject:ShowMobileContact forKey:@"ShowMobileContact"];
//                NSString *ShowEmailContact = [[NSString alloc] initWithUTF8String:
//                                              (const char *) sqlite3_column_text(statement, 16)];
//                [resultArray setObject:ShowEmailContact forKey:@"ShowEmailContact"];
//                NSString *ShowEmployer = [[NSString alloc] initWithUTF8String:
//                                          (const char *) sqlite3_column_text(statement, 17)];
//                [resultArray setObject:ShowEmployer forKey:@"ShowEmployer"];
//                NSString *ShowJob = [[NSString alloc] initWithUTF8String:
//                                     (const char *) sqlite3_column_text(statement, 18)];
//                [resultArray setObject:ShowJob forKey:@"ShowJob"];
//                NSString *ShowSchool = [[NSString alloc] initWithUTF8String:
//                                        (const char *) sqlite3_column_text(statement, 19)];
//                [resultArray setObject:ShowSchool forKey:@"ShowSchool"];
//                NSString *NewMatch = [[NSString alloc] initWithUTF8String:
//                                      (const char *) sqlite3_column_text(statement, 20)];
//                [resultArray setObject:NewMatch forKey:@"NewMatch"];
//                NSString *Chats = [[NSString alloc] initWithUTF8String:
//                                   (const char *) sqlite3_column_text(statement, 21)];
//                [resultArray setObject:Chats forKey:@"Chats"];
//
//                NSString *showPlaces = [[NSString alloc] initWithUTF8String:
//                                   (const char *) sqlite3_column_text(statement, 22)];
//                [resultArray setObject:showPlaces forKey:@"showPlaces"];
//
//                sqlite3_finalize(statement);
//                //  sqlite3_close(database);
//                
//                return resultArray;
//            }
//            else{
//                NSLog(@"Not found");
//                return nil;
//            }
//            
//        }
//        
//    }
//    
//    return nil;
//}
//
//#pragma mark - FB user profile
//
//- (void) delete_tbl_FBProfile {
//    
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK){
//        NSString *insertSQL = [NSString stringWithFormat:@"delete from tbl_FBUserDetail"];
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE){
//            sqlite3_finalize(statement);
//            NSLog(@"delete profile from local db success");
//        }
//        else {
//            NSLog(@"failed to delete profile in local db");
//        }
//    }
//}
//
//- (BOOL)insertFBdetails:(NSMutableDictionary*)dicUserDetail
//{
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        char* errorMessage;
//        sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
//        
//        NSString *str_facebook_id = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"facebook_id"]];
//        NSString *str_name = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"name"]];
//        NSString *str_email = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"email"]];
//        NSString *str_gender = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"gender"]];
//        NSString *str_dob = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"dob"]];
//        NSString *str_photo = [dicUserDetail objectForKey:@"photo"];
//        NSString *str_about_me = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"about_me"]];
//        
//        str_about_me=[str_about_me stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//        
//        NSString *str_school = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"school"]];
//        str_school=[str_school stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//
//        NSString *str_job = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"job"]];
//        NSString *str_employer = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"employer"]];
//        str_employer=[str_employer stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//
//        NSString *str_interest = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"interest"]];
//        str_interest = [str_interest stringByReplacingOccurrencesOfString:@"'" withString:@""];
//        NSString *str_mobile = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"mobile"]];
//        NSString *str_gcm_id = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"gcm_id"]];
//        NSString *str_InstagramId = [NSString stringWithFormat:@"%@", @"InstagramId"];
//        NSString *str_FBRelationship = [NSString stringWithFormat:@"%@", @"FBRelationship"];
//        NSString *str_birthDay = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"birthDay"]];
//        NSString *str_hometown = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"hometown"]];
//        NSString *str_location = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"location"]];
//        
//        NSString *query = [NSString stringWithFormat:@"INSERT INTO tbl_FBUserDetail (facebook_id, name, email, gender, dob, photo, about_me, school, job, employer, interest, mobile, gcm_id, InstagramId, FBRelationship, birthDay,Hometown,Location) values('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')",str_facebook_id, str_name, str_email, str_gender, str_dob, str_photo, str_about_me, str_school, str_job, str_employer, str_interest, str_mobile, str_gcm_id, str_InstagramId, str_FBRelationship, str_birthDay,str_hometown,str_location];
//        
//        if (sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//        {
//            NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
//            return NO;
//        }
//        
//        sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
//    }
//    
//    NSLog(@"success fb detail insert in local");
//    return YES;
//    
//    
//    
///*    NSString *query = [NSString stringWithFormat:@"INSERT INTO tbl_FBUserDetail (facebook_id, name, email, gender, dob, photo, about_me, school, job, employer, interest, mobile, gcm_id, InstagramId, FBRelationship, birthDay,Hometown,Location) values(?, ?, ?, ?, ?, ?,?, ?, ?, ?, ?, ?,?, ?, ?, ?, ?, ?)"];
//
//    NSString *query = [NSString stringWithFormat:@"INSERT INTO tbl_FBUserDetail (facebook_id, name, email) values(?, ?, ?)"];
//
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//
//            char* errorMessage;
//            sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
//            
//            sqlite3_bind_text(statement, 0, [[dicUserDetail objectForKey:@"facebook_id"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(statement, 1, [[dicUserDetail objectForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 2, [[dicUserDetail objectForKey:@"email"] UTF8String], -1, SQLITE_TRANSIENT);
//
//        
//            if (sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//            {
//                NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
//                return NO;
//            }
//            
//            sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
//    }
//    NSLog(@"success fb detail insert in local");
//    return YES;*/
//
//}
//
//- (BOOL)updateFBdetails:(NSMutableDictionary*)dicUserDetail {
//    
//    NSString *str_facebook_id = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"facebook_id"]];
//    NSString *str_name = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"name"]];
//    NSString *str_email = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"email"]];
//    NSString *str_gender = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"gender"]];
//    NSString *str_dob = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"dob"]];
//    NSString *str_birthDay = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"birthDay"]];
//    NSString *str_photo = [dicUserDetail objectForKey:@"photo"];
//    NSString *str_about_me = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"about_me"]];
//    str_about_me=[str_about_me stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
//    NSString *str_school = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"school"]];
//    NSString *str_job = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"job"]];
//    NSString *str_employer = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"employer"]];
//    NSString *str_interest = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"interest"]];
//    str_interest = [str_interest stringByReplacingOccurrencesOfString:@"'" withString:@""];
//    NSString *str_mobile = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"mobile"]];
//    NSString *str_gcm_id = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"gcm_id"]];
//    NSString *str_InstagramId = [NSString stringWithFormat:@"%@", @""];
//    NSString *str_FBRelationship = [NSString stringWithFormat:@"%@", @""];
//    NSString *str_hometown = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"hometown"]];
//    NSString *str_location = [NSString stringWithFormat:@"%@", [dicUserDetail objectForKey:@"location"]];
//    NSString *query = [NSString stringWithFormat:@"UPDATE tbl_FBUserDetail SET facebook_id = '%@', name = '%@', email = '%@', gender = '%@', dob = '%@', photo = '%@', about_me = '%@', school = '%@', job = '%@', employer = '%@', interest = '%@', mobile = '%@', gcm_id = '%@', InstagramId = '%@', FBRelationship = '%@', birthDay = '%@',Hometown = '%@', Location = '%@' WHERE rowid = 1",str_facebook_id, str_name, str_email, str_gender, str_dob, str_photo, str_about_me, str_school, str_job, str_employer, str_interest, str_mobile, str_gcm_id, str_InstagramId, str_FBRelationship, str_birthDay,str_hometown,str_location];
//    
//    [self executeQuery:query];
//    return NO;
//
//}
//
//- (void)updateFBDetailByKey:(NSString *)key Value:(NSString *)valu {
//    
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
//        NSString *insertSQL = [NSString stringWithFormat:@"UPDATE tbl_FBUserDetail SET %@ = '%@' WHERE rowid = 1",key, valu];
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE) {
//            NSLog(@"Success update in local db");
//            sqlite3_finalize(statement);
//            sqlite3_close(database);
//        }
//        else {
//            NSLog(@"failed to insert in local db");
//        }
//    }
//}
//
//-(void)executeQuery:(NSString *)query {
//    sqlite3_stmt *statement;
//    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
//        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL) == SQLITE_OK) {
//            if (sqlite3_step(statement) != SQLITE_DONE) {
//                sqlite3_finalize(statement);
//            }
//        }else {
//            NSLog(@"query Statement Not Compiled");
//        }
//        sqlite3_finalize(statement);
//        sqlite3_close(database);
//    }else{
//        NSLog(@"Data not Opened");
//    }
//}
//
//-(NSMutableDictionary*) getFBProfile {
//    
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
//    {
//        NSString *querySQL = [NSString stringWithFormat:@"select * from tbl_FBUserDetail"];
//        const char *query_stmt = [querySQL UTF8String];
//        NSMutableDictionary *resultArray = [[NSMutableDictionary alloc]init];
//        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK){
//            if (sqlite3_step(statement) == SQLITE_ROW){
//                NSString *FBid = [[NSString alloc] initWithUTF8String:
//                                  (const char *) sqlite3_column_text(statement, 0)];
//                [resultArray setObject:[NSString stringWithFormat:@"%@",FBid] forKey:@"facebook_id"];
//                NSString *FBName = [[NSString alloc] initWithUTF8String:
//                                    (const char *) sqlite3_column_text(statement, 1)];
//                [resultArray setObject:[NSString stringWithFormat:@"%@",FBName] forKey:@"name"];
//                NSString *FBMail = [[NSString alloc] initWithUTF8String:
//                                    (const char *) sqlite3_column_text(statement, 2)];
//                [resultArray setObject:[NSString stringWithFormat:@"%@",FBMail] forKey:@"email"];
//                NSString *FBGender = [[NSString alloc] initWithUTF8String:
//                                      (const char *) sqlite3_column_text(statement, 3)];
//                [resultArray setObject:[NSString stringWithFormat:@"%@",FBGender] forKey:@"gender"];
//                NSString *FBDOB = [[NSString alloc] initWithUTF8String:
//                                   (const char *) sqlite3_column_text(statement, 4)];
//                [resultArray setObject:[NSString stringWithFormat:@"%@",FBDOB] forKey:@"dob"];
//                NSString *FBProifleImage = [[NSString alloc] initWithUTF8String:
//                                            (const char *) sqlite3_column_text(statement, 5)];
//                [resultArray setObject:[NSString stringWithFormat:@"%@",FBProifleImage] forKey:@"photo"];
//                NSString *FBBio = [[NSString alloc] initWithUTF8String:
//                                   (const char *) sqlite3_column_text(statement, 6)];
//                [resultArray setObject:[NSString stringWithFormat:@"%@",FBBio] forKey:@"about_me"];
//                NSString *FBSchoolName = [[NSString alloc] initWithUTF8String:
//                                          (const char *) sqlite3_column_text(statement, 7)];
//                [resultArray setObject:[NSString stringWithFormat:@"%@",FBSchoolName] forKey:@"school"];
//                NSString *FBJob = [[NSString alloc] initWithUTF8String:
//                                   (const char *) sqlite3_column_text(statement, 8)];
//                [resultArray setObject:[NSString stringWithFormat:@"%@",FBJob] forKey:@"job"];
//                NSString *FBEmployee = [[NSString alloc] initWithUTF8String:
//                                        (const char *) sqlite3_column_text(statement, 9)];
//                [resultArray setObject:[NSString stringWithFormat:@"%@",FBEmployee] forKey:@"employer"];
//                NSString *FBInterest = [[NSString alloc] initWithUTF8String:
//                                        (const char *) sqlite3_column_text(statement, 10)];
//                [resultArray setObject:[NSString stringWithFormat:@"%@",FBInterest] forKey:@"interest"];
//                NSString *FBContact = [[NSString alloc] initWithUTF8String:
//                                       (const char *) sqlite3_column_text(statement, 11)];
//                [resultArray setObject:[NSString stringWithFormat:@"%@",FBContact] forKey:@"mobile"];
//                NSString *gcm_id = [[NSString alloc] initWithUTF8String:
//                                    (const char *) sqlite3_column_text(statement, 12)];
//                [resultArray setObject:[NSString stringWithFormat:@"%@",gcm_id] forKey:@"gcm_id"];
//                NSString *InstagramId = [[NSString alloc] initWithUTF8String:
//                                         (const char *) sqlite3_column_text(statement, 13)];
//                NSString *FBRelationship = [[NSString alloc] initWithUTF8String:
//                                            (const char *) sqlite3_column_text(statement, 14)];
//                [resultArray setObject:[NSString stringWithFormat:@"%@",FBRelationship] forKey:@"FBRelationship"];
//                NSString *birthDay = [[NSString alloc] initWithUTF8String:
//                                      (const char *) sqlite3_column_text(statement, 15)];
//                [resultArray setObject:[NSString stringWithFormat:@"%@",birthDay] forKey:@"birthDay"];
//                NSString *hometown = [[NSString alloc] initWithUTF8String:
//                                      (const char *) sqlite3_column_text(statement, 16)];
//                [resultArray setObject:[NSString stringWithFormat:@"%@",hometown] forKey:@"hometown"];
//                NSString *location = [[NSString alloc] initWithUTF8String:
//                                      (const char *) sqlite3_column_text(statement, 17)];
//                [resultArray setObject:[NSString stringWithFormat:@"%@",location] forKey:@"location"];
//                sqlite3_finalize(statement);
//                return resultArray;
//            }else{
//                NSLog(@"Not found");
//                return nil;
//            }
//        }
//        
//        NSLog(@"all array %@",resultArray);
//        
//    }
//    
//    return nil;
//}
//
//#pragma mark
//#pragma mark Home Database actions
//
////  -- > old version  <-- ///
//
////- (BOOL) saveDataIn_tbl_NearbyPlaces:(NSArray*)arrayData
////{
//////    const char *dbpath = [databasePath UTF8String];
////    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
////    {
////        char* errorMessage;
////        sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
////        
////        for (int i =0; i <[arrayData count]; i++)
////        {
////            serviceManager = [arrayData objectAtIndex:i];
////            NSString *query=[NSString stringWithFormat:@"insert into tbl_NearbyPlaces (PlaceName , PlaceID , PlacePhone , PlaceAddress , PlaceCity ,PlaceDistance , PlaceLat  , Placelng ,PlaceIcon) values (\"%@\",\"%@\", \"%@\", \"%@\",\"%@\",\"%@\", \"%@\", \"%@\",\"%@\")",serviceManager.str_Nearby_PlaceName,serviceManager.str_Nearby_PlaceId, serviceManager.str_Nearby_PlacePhone, serviceManager.str_Nearby_PlaceAddress,serviceManager.str_Nearby_PlaceCity,serviceManager.str_Nearby_PlaceDistance,serviceManager.str_Nearby_PlaceLat,serviceManager.str_Nearby_PlaceLng,serviceManager.str_Nearby_PlaceIconUrl];
////            
////            if (sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
////            {
////                NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
////                return NO;
////            }
////            
////        }
////        
////        sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
////    }
////    
////    NSLog(@"success dfdsf");
////    
////    return YES;
////}
//
//
//- (BOOL) saveDataIn_tbl_NearbyPlaces:(NSArray*)arrayData
//{
//    //    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        char* errorMessage;
//        sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
//        
//        for (int i =0; i <[arrayData count]; i++)
//        {
//            NSMutableArray *arr = [arrayData objectAtIndex:i];
//
//            NSString *m = [arr valueForKey:@"distance"];
//            NSInteger meters = [m doubleValue]*1000;
//            NSString *str_Meters = [NSString stringWithFormat:@"%ld",(long)meters];
//            
//            NSArray *venue_timing = [arr valueForKey:@"venue_timing"];
//            NSString *venueTimeing = [NSString stringWithFormat:@"%@",venue_timing];
//            
//
//            NSData *data = [venueTimeing dataUsingEncoding:NSUTF8StringEncoding];
//            id json = [NSJSONSerialization JSONObjectWithData:data
//                                                      options:0 error:nil];
//            
//
//            NSArray *groups1= [json objectAtIndex:0];
//            NSMutableArray *days= [groups1 valueForKey:@"days"];
//            NSString *str_days = [days componentsJoinedByString:@","];
//
//            NSArray *open1= [groups1 valueForKey:@"open"];
//                    
//            NSDictionary *open = [open1 objectAtIndex:0];
//
//            NSString *str_open = [NSString stringWithFormat:@"%@,%@",[open objectForKey:@"start"],[open objectForKey:@"end"]];
//
//            NSString *photo_ref = [Utils resizeImage:[arr valueForKey:@"photo_ref"]];
//
//            
//            NSString *description = @"";
//            if (![[arr valueForKey:@"description"] isEqual:[NSNull null]])
//            {
//                description = [[arr valueForKey:@"description"] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//            }
//
//            
//            NSString *query=[NSString stringWithFormat:@"insert into tbl_NearbyPlaces (PlaceName , PlaceID , PlacePhone , PlaceAddress ,PlaceDistance , PlaceLat  , Placelng ,PlaceIcon,description,opening_days,opening_time,website) values (\"%@\", \"%@\", \"%@\",\"%@\",\"%@\", \"%@\", \"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",[arr valueForKey:@"name"],[arr valueForKey:@"place_id"],[arr valueForKey:@"formatted_phone"],[arr valueForKey:@"vicinity"],str_Meters,[arr valueForKey:@"latitude"],[arr valueForKey:@"longitude"],photo_ref,description,str_days,str_open,[arr valueForKey:@"website"]];
//            
//            sqlite3_prepare_v2(database, [query UTF8String],-1, &statement, NULL);
//
//            if (sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//            {
//                NSLog(@"%@",[arr valueForKey:@"name"]);
//                NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
//                return NO;
//            }
//            
//        }
//        
//        sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
//    }
//    
//    NSLog(@"success dfdsf");
//    
//    return YES;
//}
//
//
//
//- (void) deleteAllRowsIn_tbl_NearbyPlaces
//{
////    const char *dbpath = [databasePath UTF8String];
//    
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *insertSQL = [NSString stringWithFormat:@"delete from tbl_NearbyPlaces"];
//        
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE)
//        {
//            NSLog(@"delete success");
//            
//            sqlite3_finalize(statement);
//            // sqlite3_close(database);
//        }
//        else {
//            NSLog(@"failed to delete");
//        }
//    }
//}
//
//- (NSMutableArray*)getAllDetailsFrom_tbl_NearbyPlaces
//{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    
//    // Setup the database object
//    sqlite3 *database;
//    
//    // Open the database from the users filessytem
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        // Setup the SQL Statement and compile it for faster access
//        //Where PlaceDistance  BETWEEN '0' AND '100'
//        //SQLIte Statement
//        
//        //order by PlaceDistance asc
//        NSString *sqlStatement_userInfo =[NSString stringWithFormat:@"Select * from tbl_NearbyPlaces order by cast(PlaceDistance as REAL) asc"];
//        
//        sqlite3_stmt *compiledStatement;
//        
//        
//        if(sqlite3_prepare_v2(database, [sqlStatement_userInfo UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
//        {
//            
//            //    PlaceName , PlaceID , PlacePhone , PlaceAddress , PlaceCity ,PlaceDistance , PlaceLat  , Placelng ,PlaceIcon
//            
//            // Loop through the results and add them to the feeds array
//            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
//                // Init the Data Dictionary
//                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
//                
//                NSString *ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                NSString *PlaceName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                NSString *PlaceID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
//                NSString *PlacePhone = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
//                NSString *PlaceAddress = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
//                NSString *PlaceDistance = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
//                NSString *PlaceLat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
//                NSString *Placelng = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
//                NSString *PlaceIcon = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
//                NSString *description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)];
//                
////                NSUInteger blobLength = sqlite3_column_bytes(compiledStatement, 10);
////                NSData *data = [NSData dataWithBytes:sqlite3_column_blob(compiledStatement, 10) length:blobLength];
//
//                
//                NSString *opening_days = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 10)];
//
//                NSString *opening_time = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 11)];
//
//                NSString *website = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 12)];
////
////                NSDictionary *dictionary=[NSJSONSerialization
////                                          JSONObjectWithData:data
////                                          options:kNilOptions
////                                          error:nil];
////                id json = [NSJSONSerialization JSONObjectWithData:data
////                                                          options:0 error:nil];
////
////                
//////                NSData* data = [venue_timing dataUsingEncoding:NSUTF8StringEncoding];
//////
////                NSDictionary *myArrayFromDB = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//
//                
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",ID] forKey:@"ID"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceName] forKey:@"name"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceID] forKey:@"place_id"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlacePhone] forKey:@"formatted_phone"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceAddress] forKey:@"vicinity"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceDistance] forKey:@"distance"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceLat] forKey:@"latitude"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",Placelng] forKey:@"longitude"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceIcon] forKey:@"photo_ref"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",description] forKey:@"description"];
//                
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",opening_days] forKey:@"opening_days"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",opening_time] forKey:@"opening_time"];
//
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",website] forKey:@"website"];
//
//                
//                [array addObject:dataDictionary];
//            }
//            
//            sqlite3_finalize(compiledStatement);
//            
//        }
//        else
//        {
//            NSLog(@"No Data Found");
//        }
//        
//        // Release the compiled statement from memory
//    }
//    
//    // sqlite3_close(database);
//    
//    return array;
//}
//
//
//
//#pragma mark - tbl_CheckInPlaces
//
//
//- (BOOL) insertFirstTimeIn_tbl_CheckInPlaces:(NSArray*)arrayData
//{
////    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        char* errorMessage;
//        sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
//        
//        for (int i =0; i <[arrayData count]; i++)
//        {
//            serviceManager = [arrayData objectAtIndex:i];
//            NSString *query=[NSString stringWithFormat:@"insert into tbl_CheckInPlaces  (PlaceID,PlaceName,PlacePhone,PlaceAddress,PlaceLat,Placelng,PlaceIcon,Date,CurrentStatus) values (\"%@\",\"%@\", \"%@\", \"%@\",\"%@\",\"%@\", \"%@\", \"%@\",\"%@\",\"%@\",\"%@\")",serviceManager.str_MyVenue_PlaceId,serviceManager.str_MyVenue_PlaceName,serviceManager.str_MyVenue_PlacePhone,serviceManager.str_MyVenue_PlaceAddress,serviceManager.str_MyVenue_PlaceLat,serviceManager.str_MyVenue_PlaceLng];
//            
//            if (sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//            {
//                NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
//                return NO;
//            }
//            
//        }
//        sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
//    }
//    
//    NSLog(@"success dfdsf");
//    
//    return YES;
//}
//
//- (BOOL) insertIn_tbl_CheckInPlaces:(NSMutableDictionary*)arrayData
//{
//    NSString *placeId= [arrayData valueForKey:@"PlaceID"];
//    
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        char* errorMessage;
//        
//        NSString *insertSQL = [NSString stringWithFormat:@"delete from tbl_CheckInPlaces Where PlaceID = \"%@\"",placeId];
//        
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE)
//        {
//            NSLog(@"delete success");
//            
//            NSString *query = [NSString stringWithFormat:@"insert into tbl_CheckInPlaces (PlaceID,PlaceName,PlacePhone,PlaceAddress,PlaceCity,PlaceDistance,PlaceLat,Placelng,PlaceIcon,Date,CurrentStatus) values (\"%@\",\"%@\", \"%@\", \"%@\",\"%@\",\"%@\", \"%@\", \"%@\",\"%@\",\"%@\",\"%@\")",[arrayData valueForKey:@"PlaceID"],[arrayData valueForKey:@"PlaceName"],[arrayData valueForKey:@"PlacePhone"],[arrayData valueForKey:@"PlaceAddress"],[arrayData valueForKey:@"PlaceCity"],[arrayData valueForKey:@"PlaceDistance"],[arrayData valueForKey:@"PlaceLat"],[arrayData valueForKey:@"Placelng"],[arrayData valueForKey:@"PlaceIcon"],[arrayData valueForKey:@"Date"],[arrayData valueForKey:@"CurrentStatus"]];
//            
//            if (sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//            {
//                NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
//                return NO;
//            }
//            else
//            {
//                NSString *query2 = [NSString stringWithFormat:@"insert into tbl_CheckInTimeInOut (CheckInTime,CheckOutTime,CheckInPlaceID) values (\"%@\",'0',\"%@\")",[arrayData valueForKey:@"Date"],[arrayData valueForKey:@"PlaceID"]];
//                
//                if (sqlite3_exec(database, [query2 UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//                {
//                    NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
//                    return NO;
//                }
//                else
//                {
//                    NSLog(@"inserted successfully");
//                }
//            }
//            
//            sqlite3_finalize(statement);
//            sqlite3_close(database);
//        }
//        else
//        {
//            NSLog(@"failed to delete");
//            
//            //            NSString *query = [NSString stringWithFormat:@"insert into tbl_CheckInPlaces (PlaceID,PlaceName,PlacePhone,PlaceAddress,PlaceCity,PlaceDistance,PlaceLat,Placelng,PlaceIcon,Date,CurrentStatus) values (\"%@\",\"%@\", \"%@\", \"%@\",\"%@\",\"%@\", \"%@\", \"%@\",\"%@\",\"%@\",\"%@\")",[arrayData valueForKey:@"PlaceID"],[arrayData valueForKey:@"PlaceName"],[arrayData valueForKey:@"PlacePhone"],[arrayData valueForKey:@"PlaceAddress"],[arrayData valueForKey:@"PlaceCity"],[arrayData valueForKey:@"PlaceDistance"],[arrayData valueForKey:@"PlaceLat"],[arrayData valueForKey:@"Placelng"],[arrayData valueForKey:@"PlaceIcon"],[arrayData valueForKey:@"Date"],[arrayData valueForKey:@"CurrentStatus"]];
//            //
//            //            if (sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//            //            {
//            //                NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
//            //                return NO;
//            //            }
//            //            else
//            //            {
//            //                NSString *query2 = [NSString stringWithFormat:@"insert into tbl_CheckInTimeInOut (CheckInTime,CheckOutTime,CheckInPlaceID) values (\"%@\",'0',\"%@\")",[arrayData valueForKey:@"Date"],[arrayData valueForKey:@"PlaceID"]];
//            //
//            //                if (sqlite3_exec(database, [query2 UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//            //                {
//            //                    NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
//            //                    return NO;
//            //                }
//            //                else
//            //                {
//            //                    NSLog(@"inserted successfully");
//            //                }
//            //            }
//            //
//            //            sqlite3_finalize(statement);
//            //            sqlite3_close(database);
//            //
//        }
//    }
//    
//    
//    return false;
//    
//    /*    sqlite3 *database;
//     
//     NSString *placeId= [arrayData valueForKey:@"PlaceID"];
//     if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//     {
//     char* errorMessage;
//     
//     NSString *sqlStatement_userInfo =[NSString stringWithFormat:@"Select * from tbl_CheckInPlaces Where  PlaceID = \"%@\"",placeId];
//     
//     sqlite3_stmt *compiledStatement;
//     if(sqlite3_prepare_v2(database, [sqlStatement_userInfo UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
//     {
//     
//     // Loop through the results and add them to the feeds array
//     if(sqlite3_step(compiledStatement) == SQLITE_ROW)
//     {
//     NSLog(@"Row exit");
//     
//     // if place/venue already exist in checkIn places table
//     
//     NSString *insertSQL = [NSString stringWithFormat:@"delete from tbl_CheckInPlaces Where PlaceID = \"%@\"",placeId];
//     
//     const char *insert_stmt = [insertSQL UTF8String];
//     sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//     if (sqlite3_step(statement) == SQLITE_DONE)
//     {
//     NSLog(@"delete success");
//     
//     sqlite3_finalize(statement);
//     // sqlite3_close(database);
//     }
//     else {
//     NSLog(@"failed to delete");
//     }
//     
//     
//     
//     const char *sql = "update tbl_CheckInPlaces Set CurrentStatus = ? , Date = ? where PlaceID = ?";
//     if(sqlite3_prepare_v2(database, sql, -1, &compiledStatement, NULL)==SQLITE_OK)
//     {
//     sqlite3_bind_text(compiledStatement, 1, [[arrayData objectForKey:@"CurrentStatus"] UTF8String], -1, SQLITE_TRANSIENT); //1
//     sqlite3_bind_text(compiledStatement, 2, [[arrayData objectForKey:@"Date"] UTF8String], -1, SQLITE_TRANSIENT);
//     sqlite3_bind_text(compiledStatement, 3, [[arrayData objectForKey:@"PlaceID"] UTF8String], -1, SQLITE_TRANSIENT);
//     
//     if(SQLITE_DONE != sqlite3_step(compiledStatement))
//     {
//     NSLog(@"Error while updating. %s", sqlite3_errmsg(database));
//     }
//     else
//     {
//     NSString *query2 = [NSString stringWithFormat:@"insert into tbl_CheckInTimeInOut (CheckInTime,CheckOutTime,CheckInPlaceID) values (\"%@\",'0',\"%@\")",[arrayData valueForKey:@"Date"],[arrayData valueForKey:@"PlaceID"]];
//     
//     if (sqlite3_exec(database, [query2 UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//     {
//     NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
//     return NO;
//     }
//     else
//     {
//     NSLog(@"inserted successfully");
//     
//     }
//     
//     }
//     
//     }
//     
//     
//     
//     
//     
//     }
//     else
//     {
//     NSLog(@"not exist");
//     
//     NSString *query = [NSString stringWithFormat:@"insert into tbl_CheckInPlaces (PlaceID,PlaceName,PlacePhone,PlaceAddress,PlaceCity,PlaceDistance,PlaceLat,Placelng,PlaceIcon,Date,CurrentStatus) values (\"%@\",\"%@\", \"%@\", \"%@\",\"%@\",\"%@\", \"%@\", \"%@\",\"%@\",\"%@\",\"%@\")",[arrayData valueForKey:@"PlaceID"],[arrayData valueForKey:@"PlaceName"],[arrayData valueForKey:@"PlacePhone"],[arrayData valueForKey:@"PlaceAddress"],[arrayData valueForKey:@"PlaceCity"],[arrayData valueForKey:@"PlaceDistance"],[arrayData valueForKey:@"PlaceLat"],[arrayData valueForKey:@"Placelng"],[arrayData valueForKey:@"PlaceIcon"],[arrayData valueForKey:@"Date"],[arrayData valueForKey:@"CurrentStatus"]];
//     
//     if (sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//     {
//     NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
//     return NO;
//     }
//     else
//     {
//     NSString *query2 = [NSString stringWithFormat:@"insert into tbl_CheckInTimeInOut (CheckInTime,CheckOutTime,CheckInPlaceID) values (\"%@\",'0',\"%@\")",[arrayData valueForKey:@"Date"],[arrayData valueForKey:@"PlaceID"]];
//     
//     if (sqlite3_exec(database, [query2 UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//     {
//     NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
//     return NO;
//     }
//     else
//     {
//     NSLog(@"inserted successfully");
//     }
//     }
//     
//     }
//     
//     sqlite3_busy_timeout(database, 500);
//     
//     sqlite3_finalize(compiledStatement);
//     sqlite3_close(database);
//     
//     }
//     else
//     {
//     NSLog(@"No Data Found '%s'", sqlite3_errmsg(database));
//     
//     }
//     
//     // Release the compiled statement from memory
//     
//     }
//     
//     return false;
//     */
//    
//}
//
//- (NSMutableArray*)getAllDetailsFrom_tbl_CheckInPlaces
//{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    
//    // Setup the database object
//    sqlite3 *database;
//    
//    // Open the database from the users filessytem
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *sqlStatement_userInfo =[NSString stringWithFormat:@"Select * from tbl_CheckInPlaces order by ID desc "];
//        
//        sqlite3_stmt *compiledStatement;
//        
//        
//        if(sqlite3_prepare_v2(database, [sqlStatement_userInfo UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
//        {
//            //
//            //            ID INTEGER PRIMARY KEY AUTOINCREMENT,PlaceID TEXT,PlaceName text,PlacePhone Text,PlaceAddress Text, PlaceCity Text,PlaceDistance Text, PlaceLat Text , Placelng Text,PlaceIcon Text,Date Text,Time Text,CurrentStatus Text
//            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
//                // Init the Data Dictionary
//                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
//                
//                NSString *ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                NSString *PlaceID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                NSString *PlaceName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
//                NSString *PlacePhone = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
//                NSString *PlaceAddress = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
//                NSString *PlaceCity = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
//                NSString *PlaceDistance = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
//                NSString *PlaceLat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
//                NSString *Placelng = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
//                NSString *PlaceIcon = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)];
//                NSString *Date = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 10)];
//                NSString *CurrentStatus = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 11)];
//                
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",ID] forKey:@"ID"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceName] forKey:@"PlaceName"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceID] forKey:@"PlaceID"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlacePhone] forKey:@"PlacePhone"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceAddress] forKey:@"PlaceAddress"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceCity] forKey:@"PlaceCity"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceDistance] forKey:@"PlaceDistance"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceLat] forKey:@"PlaceLat"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",Placelng] forKey:@"Placelng"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceIcon] forKey:@"PlaceIcon"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",Date] forKey:@"Date"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",CurrentStatus] forKey:@"CurrentStatus"];
//                
//                [array addObject:dataDictionary];
//                
//            }
//            
//        }
//        else
//        {
//            NSLog(@"No Data Found %s", sqlite3_errmsg(database));
//        }
//        sqlite3_busy_timeout(database, 500);
//        
//        // Release the compiled statement from memory
//        sqlite3_finalize(compiledStatement);
//        sqlite3_close(database);
//        
//    }
//    
//    
//    
//    return array;
//}
//
//
//- (NSMutableDictionary*)getLastInsertedRowFrom_tbl_CheckInPlaces
//{
//    
//    NSMutableDictionary *resultArray = [[NSMutableDictionary alloc]init];
//    
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *querySQL = [NSString stringWithFormat:@"Select * from tbl_CheckInPlaces WHERE CurrentStatus = '2'"];
//        const char *query_stmt = [querySQL UTF8String];
//        
//        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
//        {
//            
//            if (sqlite3_step(statement) == SQLITE_ROW)
//            {
//                NSString *PlaceID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
//                [resultArray setObject:PlaceID forKey:@"PlaceID"];
//                
//                NSString *PlaceName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
//                [resultArray setObject:PlaceName forKey:@"PlaceName"];
//                
//                NSString *ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
//                [resultArray setObject:ID forKey:@"ID"];
//                
//                NSString *PlaceLat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 7)];
//                [resultArray setObject:PlaceLat forKey:@"PlaceLat"];
//
//                NSString *Placelng = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 8)];
//                [resultArray setObject:Placelng forKey:@"Placelng"];
//
//                sqlite3_finalize(statement);
//                sqlite3_close(database);
//                return resultArray;
//                
//            }
//            else
//            {
//                NSLog(@"Not found");
//            }
//            sqlite3_finalize(statement);
//            
//            
//        }
//        
//        sqlite3_close(database);
//        
//    }
//    
//    return resultArray;
//    
//}
//
//
//-(BOOL)updateCheckOut_tbl_CheckInPlaces:(NSMutableDictionary*)arrayData
//{
//    sqlite3_stmt *updateStmt;
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        //        sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errmsg);
//        
//        const char *sql = "update tbl_CheckInPlaces Set CurrentStatus = ? where PlaceID = ?";
//        if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL)==SQLITE_OK)
//        {
//            sqlite3_bind_text(updateStmt, 1, [[arrayData objectForKey:@"CurrentStatus"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 2, [[arrayData objectForKey:@"PlaceID"] UTF8String], -1, SQLITE_TRANSIENT);
//            
//            if(SQLITE_DONE != sqlite3_step(updateStmt)){
//                NSLog(@"Error while updating. %s", sqlite3_errmsg(database));
//            }
//            else
//            {
//                
//                //                const char *sql2 = "update tbl_CheckInTimeInOut Set CheckOutTime = ? where CheckInPlaceID = ?";
//                //
//                //                if(sqlite3_prepare_v2(database, sql2, -1, &updateStmt, NULL)==SQLITE_OK)
//                //                {
//                //                    sqlite3_bind_text(updateStmt, 1, [[arrayData objectForKey:@"Date"] UTF8String], -1, SQLITE_TRANSIENT);
//                //                    sqlite3_bind_text(updateStmt, 2, [[arrayData objectForKey:@"PlaceID"] UTF8String], -1, SQLITE_TRANSIENT);
//                //
//                //                    if(SQLITE_DONE != sqlite3_step(updateStmt)){
//                //                        NSLog(@"Error while updating. %s", sqlite3_errmsg(database));
//                //                    }
//                //                    else
//                //                    {
//                //                        NSLog(@"suces");
//                //                    }
//                //
//                //                }
//            }
//            
//            
//        }
//        else
//        {
//            NSLog(@"FAIL");
//        }
//        
//        
//        sqlite3_busy_timeout(database, 500);
//        
//        // sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errmsg);
//        sqlite3_finalize(updateStmt);
//        sqlite3_close(database);
//        
//        
//    }
//    else
//    {
//        NSLog(@"No Data Found %s", sqlite3_errmsg(database));
//        
//    }
//    
//    
//    
//    return NO;
//}
//
//
//#pragma mark - tbl_CheckInTimeInOut
//
//-(BOOL)updateCheckOut_tbl_CheckInTimeInOut:(NSMutableDictionary*)arrayData
//{
//    
//    
//    sqlite3_stmt *updateStmt;
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        // sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errmsg);
//        const char *sql2 = "update tbl_CheckInTimeInOut Set CheckOutTime = ? where ID = ?";
//        
//        if(sqlite3_prepare_v2(database, sql2, -1, &updateStmt, NULL)==SQLITE_OK)
//        {
//            sqlite3_bind_text(updateStmt, 1, [[arrayData objectForKey:@"Date"] UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(updateStmt, 2, [[arrayData objectForKey:@"ID"] UTF8String], -1, SQLITE_TRANSIENT);
//            
//            if(SQLITE_DONE != sqlite3_step(updateStmt)){
//                NSLog(@"Error while updating. %s", sqlite3_errmsg(database));
//            }
//            else
//            {
//                NSLog(@"suces");
//            }
//            
//        }
//        else
//        {
//            NSLog(@"FAIL");
//        }
//        
//        sqlite3_busy_timeout(database, 500);
//        
//        sqlite3_finalize(updateStmt);
//        sqlite3_close(database);
//        
//        //  sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errmsg);
//        
//        
//    }
//    else
//    {
//        NSLog(@"No Data Found %s", sqlite3_errmsg(database));
//        
//    }
//    
//    
//    
//    return NO;
//}
//
//
//
//
//- (NSMutableArray*)getAllDetails_tbl_CheckInTimeInOut : (NSString*)PlaceID
//{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    
//    // Setup the database object
//    sqlite3 *database;
//    
//    // Open the database from the users filessytem
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *sqlStatement_userInfo =[NSString stringWithFormat:@"Select * from tbl_CheckInTimeInOut WHERE CheckInPlaceID =\"%@\"",PlaceID];
//        
//        sqlite3_stmt *compiledStatement;
//        
//        
//        if(sqlite3_prepare_v2(database, [sqlStatement_userInfo UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
//        {
//            //            "create table if not exists tbl_CheckInTimeInOut(ID INTEGER PRIMARY KEY AUTOINCREMENT,CheckInTime Text,CheckOutTime Text, CheckInPlaceID Text);"
//            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
//                // Init the Data Dictionary
//                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
//                
//                NSString *CheckInTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                NSString *CheckOutTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
//                
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",CheckInTime] forKey:@"CheckInTime"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",CheckOutTime] forKey:@"CheckOutTime"];
//                [array addObject:dataDictionary];
//            }
//            
//        }
//        else
//        {
//            NSLog(@"No Data Found %s", sqlite3_errmsg(database));
//        }
//        sqlite3_busy_timeout(database, 500);
//        
//        // Release the compiled statement from memory
//        sqlite3_finalize(compiledStatement);
//        sqlite3_close(database);
//        
//    }
//    
//    
//    
//    return array;
//    
//}
//
//#pragma mark - tbl_StepOnOff
//
//- (NSMutableArray*)getCheckInPlaceByCurrentStatus {
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    sqlite3 *database;
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
//        NSString *querySQL = [NSString stringWithFormat:@"Select * from tbl_StepOnOff WHERE CurrentStatus = '2'"];
//        const char *query_stmt = [querySQL UTF8String];
//        sqlite3_stmt *compiledStatement;
//        
//        if (sqlite3_prepare_v2(database, query_stmt, -1, &compiledStatement, NULL) == SQLITE_OK) {
//            if (sqlite3_step(compiledStatement) == SQLITE_ROW) {
//                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
//                
//                NSString *ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                NSString *PlaceID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                NSString *PlaceName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
//                NSString *PlacePhone = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
//                NSString *PlaceAddress = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
//                NSString *PlaceLat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
//                NSString *Placelng = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
//                NSString *CurrentStatus = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
//                NSString *Date = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
//                //PlaceID,PlaceName,PlacePhone,PlaceAddress, PlaceLat, Placelng,CurrentStatus,Date
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",ID] forKey:@"ID"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceID] forKey:@"PlaceID"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceName] forKey:@"PlaceName"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlacePhone] forKey:@"PlacePhone"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceAddress] forKey:@"PlaceAddress"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceLat] forKey:@"PlaceLat"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",Placelng] forKey:@"Placelng"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",CurrentStatus] forKey:@"CurrentStatus"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",Date] forKey:@"Date"];
//                
//                [array addObject:dataDictionary];
//                
//                sqlite3_finalize(compiledStatement);
//                sqlite3_close(database);
//                return array;
//            }
//            else{
//                NSLog(@"Not found");
//            }
//            sqlite3_finalize(compiledStatement);
//        }
//        sqlite3_close(database);
//    }
//    return array;
//}
//
//
//- (NSMutableArray*)getCheckInPlaceByPlaceId:(NSString *)placeID {
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    sqlite3 *database;
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
//        NSString *querySQL = [NSString stringWithFormat:@"Select * from tbl_StepOnOff WHERE PlaceID =\"%@\"", placeID];
//        const char *query_stmt = [querySQL UTF8String];
//        sqlite3_stmt *compiledStatement;
//        
//        if (sqlite3_prepare_v2(database, query_stmt, -1, &compiledStatement, NULL) == SQLITE_OK) {
//            if (sqlite3_step(compiledStatement) == SQLITE_ROW) {
//                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
//                
//                NSString *ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                NSString *PlaceID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                NSString *PlaceName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
//                NSString *PlacePhone = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
//                NSString *PlaceAddress = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
//                NSString *PlaceLat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
//                NSString *Placelng = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
//                NSString *CurrentStatus = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
//                NSString *Date = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
//         //PlaceID,PlaceName,PlacePhone,PlaceAddress, PlaceLat, Placelng,CurrentStatus,Date
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",ID] forKey:@"ID"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceID] forKey:@"PlaceID"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceName] forKey:@"PlaceName"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlacePhone] forKey:@"PlacePhone"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceAddress] forKey:@"PlaceAddress"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceLat] forKey:@"PlaceLat"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",Placelng] forKey:@"Placelng"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",CurrentStatus] forKey:@"CurrentStatus"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",Date] forKey:@"Date"];
//                
//                [array addObject:dataDictionary];
//                
//                sqlite3_finalize(compiledStatement);
//                sqlite3_close(database);
//                return array;
//            }
//            else{
//                NSLog(@"Not found");
//            }
//            sqlite3_finalize(compiledStatement);
//        }
//        sqlite3_close(database);
//    }
//    return array;
//}
//
//- (BOOL) insertAllUpcomingVenues_tbl_StepOnOff:(NSArray*)arrayData
//{
//
//    
//    //const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        char* errorMessage;
//        sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
//        
//
//        for (int i =0; i <[arrayData count]; i++)
//        {
//            serviceManager = [arrayData objectAtIndex:i];
//            
//            double unixTimeStamp =[serviceManager.str_MyVenue_timestamp doubleValue];
//            NSTimeInterval _interval=unixTimeStamp;
//            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
//            NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
//            [formatter setLocale:[NSLocale currentLocale]];
//            [formatter setDateFormat:@"dd-MM-yyyy hh:mm a"];
//            NSString *dateString = [formatter stringFromDate:date];
//
//            NSString *query=[NSString stringWithFormat:@"insert into tbl_StepOnOff (PlaceID,PlaceName,PlacePhone,PlaceAddress, PlaceLat, Placelng,CurrentStatus,Date) values (\"%@\",\"%@\", \"%@\", \"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",serviceManager.str_MyVenue_PlaceId,serviceManager.str_MyVenue_PlaceName, serviceManager.str_MyVenue_PlacePhone, serviceManager.str_MyVenue_PlaceAddress,serviceManager.str_MyVenue_PlaceLat,serviceManager.str_MyVenue_PlaceLng,serviceManager.str_MyVenue_AttendType,dateString];
//            
//            if (sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//            {
//                NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
//                return NO;
//            }
//            else
//            {
//                NSLog(@"Success");
//            }
//            
//        }
//        sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
//    }
//    
//    NSLog(@"success dfdsf");
//    
//    return YES;
//}
//
////////   Old Version /////
//
//
////-(BOOL) insertIn_tbl_StepOnOff:(NSMutableDictionary*)arrayData
////{
////    
////        Printing description of arr:
////        {
////            distance = "0.20523951495424755";
////            "formatted_phone" = "+97143629930";
////            latitude = "25.097366676763960";
////            longitude = "55.180330741942160";
////            name = "Blo Out Beauty Bar";
////            "photo_ref" = "";
////            "place_id" = 51f3b2c8498eab595a849a17;
////            popular = 0;
////            rating = 0;
////            vicinity = "i-Rise Tower Tecom";
////        }
////
////     const char *dbpath = [databasePath UTF8String];
////     
////     if (sqlite3_open(dbpath, &database) == SQLITE_OK)
////     {
////     NSString *insertSQL = [NSString stringWithFormat:@"insert into tbl_StepOnOff (PlaceID,PlaceName,PlacePhone,PlaceAddress,PlaceLat, Placelng,PlaceIcon,CurrentStatus,Date) values (\"%@\", \"%@\",\"%@\",\"%@\", \"%@\", \"%@\",\"%@\",\"%@\",datetime('now','localtime'))",[arrayData valueForKey:@"PlaceID"],[arrayData valueForKey:@"PlaceName"],[arrayData valueForKey:@"PlacePhone"],[arrayData valueForKey:@"PlaceAddress"],[arrayData valueForKey:@"PlaceLat"],[arrayData valueForKey:@"Placelng"],[arrayData valueForKey:@"PlaceIcon"],[arrayData valueForKey:@"CurrentStatus"]];
////     
////     const char *insert_stmt = [insertSQL UTF8String];
////     sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
////     if (sqlite3_step(statement) == SQLITE_DONE)
////     {
////     NSLog(@"Success");
////     
////     sqlite3_finalize(statement);
////     sqlite3_close(database);
////     
////     return YES;
////     
////     }
////     else {
////     NSLog(@"failed to insert");
////     
////     return NO;
////     
////     }
////     }
////     return NO;
////     
////    
////}
//
//
//-(BOOL) insertIn_tbl_StepOnOff:(NSMutableDictionary*)arrayData
//{
//        
//    const char *dbpath = [databasePath UTF8String];
//    
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
//    {
//        NSString *insertSQL = [NSString stringWithFormat:@"insert into tbl_StepOnOff (PlaceID,PlaceName,PlacePhone,PlaceAddress,PlaceLat, Placelng,Distance,PlaceIcon,CurrentStatus,Date) values (\"%@\", \"%@\",\"%@\",\"%@\", \"%@\", \"%@\", \"%@\",\"%@\",\"%@\",datetime('now','localtime'))",[arrayData valueForKey:@"place_id"],[arrayData valueForKey:@"name"],[arrayData valueForKey:@"formatted_phone"],[arrayData valueForKey:@"vicinity"],[arrayData valueForKey:@"latitude"],[arrayData valueForKey:@"longitude"],[arrayData valueForKey:@"distance"],[arrayData valueForKey:@"photo_ref"],[arrayData valueForKey:@"CurrentStatus"]];
//        
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE)
//        {
//            NSLog(@"Success");
//            
//            sqlite3_finalize(statement);
//            sqlite3_close(database);
//            
//            return YES;
//            
//        }
//        else {
//            NSLog(@"failed to insert");
//            
//            return NO;
//            
//        }
//    }
//    return NO;
//    
//    
//}
//
//- (BOOL)CheckValueExit_tbl_StepOnOff:(NSString*)PlaceID
//{
//    
//    
//    sqlite3 *database;
//    
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        
//        NSString *querySQL = [NSString stringWithFormat:@"Select * from tbl_StepOnOff WHERE PlaceID =\"%@\"",PlaceID];
//        //        NSString *querySQL = [NSString stringWithFormat:@"SELECT EXISTS(SELECT COUNT(*) FROM tbl_StepOnOff WHERE PlaceID = \"%@\" LIMIT 1)",PlaceID];
//        
//        const char *query_stmt = [querySQL UTF8String];
//        
//        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
//        {
//            
//            if (sqlite3_step(statement) == SQLITE_ROW)
//            {
//                NSLog(@"Success");
//                
//                sqlite3_finalize(statement);
//                sqlite3_close(database);
//                return true;
//                
//            }
//            else
//            {
//                NSLog(@"Not found");
//                
//            }
//            sqlite3_finalize(statement);
//        }
//        
//        sqlite3_close(database);
//        
//    }
//    
//    return false;
//    
//}
//
//- (void) deleteStepOffRow_tbl_StepOnOff:(NSString *)PlaceID
//{
//    
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *insertSQL = [NSString stringWithFormat:@"delete from tbl_StepOnOff WHERE PlaceID =\"%@\"",PlaceID];
//        
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE)
//        {
//            NSLog(@"delete success");
//            
//            sqlite3_finalize(statement);
//            // sqlite3_close(database);
//        }
//        else {
//            NSLog(@"failed to delete");
//        }
//    }
//    
//}
//- (void) deleteCheckInRow_tbl_StepOnOff
//{
//    
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//       // NSString *insertSQL = [NSString stringWithFormat:@"delete from tbl_StepOnOff WHERE CurrentStatus = '2' AND PlaceID =\"%@\"",PlaceID];
//        NSString *insertSQL = [NSString stringWithFormat:@"delete from tbl_StepOnOff WHERE CurrentStatus = '2' "];
//        
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE)
//        {
//            NSLog(@"delete success");
//            
//            sqlite3_finalize(statement);
//            // sqlite3_close(database);
//        }
//        else {
//            NSLog(@"failed to delete");
//        }
//    }
//    
//}
//
//
//- (void) deleteOlderThenOneDayRow_tbl_StepOnOff
//{
//    
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *insertSQL = [NSString stringWithFormat:@"DELETE FROM tbl_StepOnOff WHERE Date <= datetime('now', '-1440 minutes')"];
//        
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE)
//        {
//            NSLog(@"delete success later then 24 hours");
//            
//            sqlite3_finalize(statement);
//            sqlite3_close(database);
//        }
//        else {
//            NSLog(@"failed to delete");
//        }
//    }
//    
//}
//
////  -- > old version ///
//
//
//
////- (NSMutableArray*)getAllDetailsFrom_tbl_StepOnOff
////{
////    NSMutableArray *array = [[NSMutableArray alloc] init];
////    
////    // Setup the database object
////    sqlite3 *database;
////    
////    // Open the database from the users filessytem
////    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
////    {
////        NSString *sqlStatement_userInfo =[NSString stringWithFormat:@"Select * from tbl_StepOnOff"];
////        
////        sqlite3_stmt *compiledStatement;
////        
////        
////        if(sqlite3_prepare_v2(database, [sqlStatement_userInfo UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
////        {
////            // PlaceID,PlaceName,PlacePhone,PlaceAddress, PlaceCity,PlaceDistance, PlaceLat, Placelng,CurrentStatus,StepOnTime
////            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
////            {
////                
////                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
////                
////                NSString *ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
////                NSString *PlaceID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
////                NSString *PlaceName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
////                NSString *PlacePhone = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
////                NSString *PlaceAddress = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
////                NSString *PlaceLat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
////                NSString *Placelng = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
////                NSString *PlaceIcon = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
////                NSString *CurrentStatus = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
////                NSString *StepOnTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)];
////                
////                
////                [dataDictionary setObject:[NSString stringWithFormat:@"%@",ID] forKey:@"ID"];
////                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceName] forKey:@"PlaceName"];
////                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceID] forKey:@"PlaceID"];
////                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlacePhone] forKey:@"PlacePhone"];
////                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceAddress] forKey:@"PlaceAddress"];
////                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceLat] forKey:@"PlaceLat"];
////                [dataDictionary setObject:[NSString stringWithFormat:@"%@",Placelng] forKey:@"Placelng"];
////                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceIcon] forKey:@"PlaceIcon"];
////                [dataDictionary setObject:[NSString stringWithFormat:@"%@",CurrentStatus] forKey:@"CurrentStatus"];
////                [dataDictionary setObject:[NSString stringWithFormat:@"%@",StepOnTime] forKey:@"Date"];
////                
////                [array addObject:dataDictionary];
////            }
////            
////        }
////        else
////        {
////            NSLog(@"No Data Found %s", sqlite3_errmsg(database));
////        }
//////        sqlite3_busy_timeout(database, 500);
////        
////        // Release the compiled statement from memory
////        sqlite3_finalize(compiledStatement);
////        sqlite3_close(database);
////        
////    }
////    
////    
////    
////    return array;
////}
//
//- (NSMutableArray*)getAllDetailsFrom_tbl_StepOnOff
//{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    
//    // Setup the database object
//    sqlite3 *database;
//    
//    // Open the database from the users filessytem
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *sqlStatement_userInfo =[NSString stringWithFormat:@"Select * from tbl_StepOnOff"];
//        
//        sqlite3_stmt *compiledStatement;
//        
//        
//        if(sqlite3_prepare_v2(database, [sqlStatement_userInfo UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
//        {
//            // PlaceID,PlaceName,PlacePhone,PlaceAddress, PlaceCity,PlaceDistance, PlaceLat, Placelng,CurrentStatus,StepOnTime
//            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
//                
//                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
//                
//                NSString *ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                NSString *PlaceID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                NSString *PlaceName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
//                NSString *PlacePhone = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
//                NSString *PlaceAddress = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
//                NSString *PlaceLat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
//                NSString *Placelng = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
//                NSString *Distance = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
//                NSString *PlaceIcon = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
//                NSString *CurrentStatus = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)];
//                NSString *StepOnTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 10)];
//                
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",ID] forKey:@"ID"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceName] forKey:@"name"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceID] forKey:@"place_id"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlacePhone] forKey:@"formatted_phone"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceAddress] forKey:@"vicinity"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceLat] forKey:@"latitude"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",Placelng] forKey:@"longitude"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",Distance] forKey:@"distance"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceIcon] forKey:@"photo_ref"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",CurrentStatus] forKey:@"CurrentStatus"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",StepOnTime] forKey:@"Date"];
//                
//                [array addObject:dataDictionary];
//            }
//            
//        }
//        else
//        {
//            NSLog(@"No Data Found %s", sqlite3_errmsg(database));
//        }
//        //        sqlite3_busy_timeout(database, 500);
//        
//        // Release the compiled statement from memory
//        sqlite3_finalize(compiledStatement);
//        sqlite3_close(database);
//        
//    }
//    
//    
//    
//    return array;
//}
//
//
//-(NSMutableArray*)getStepOnPlaceDetail_tbl_StepOnOff:(NSString*)PlaceID
//{
//    
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//
//    sqlite3 *database;
//    
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//
//        NSString *querySQL = [NSString stringWithFormat:@"Select * from tbl_StepOnOff WHERE PlaceID =\"%@\"",PlaceID];
//        
//        const char *query_stmt = [querySQL UTF8String];
//        sqlite3_stmt *compiledStatement;
//
//        if (sqlite3_prepare_v2(database, query_stmt, -1, &compiledStatement, NULL) == SQLITE_OK)
//        {
//            
//            if (sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
//                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
//                
//                NSString *ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                NSString *PlaceID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                NSString *PlaceName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
//                NSString *PlacePhone = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
//                NSString *PlaceAddress = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
//                NSString *PlaceLat = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
//                NSString *Placelng = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
//                NSString *Distance = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)];
//                NSString *PlaceIcon = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
//                NSString *CurrentStatus = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)];
//                NSString *StepOnTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 10)];
//                
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",ID] forKey:@"ID"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceName] forKey:@"name"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceID] forKey:@"place_id"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlacePhone] forKey:@"formatted_phone"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceAddress] forKey:@"vicinity"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceLat] forKey:@"latitude"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",Placelng] forKey:@"longitude"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",Distance] forKey:@"distance"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",PlaceIcon] forKey:@"photo_ref"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",CurrentStatus] forKey:@"CurrentStatus"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",StepOnTime] forKey:@"Date"];
//                
//                [array addObject:dataDictionary];
//                
//                sqlite3_finalize(compiledStatement);
//                sqlite3_close(database);
//                return array;
//                
//            }
//            else
//            {
//                NSLog(@"Not found");
//                
//            }
//            sqlite3_finalize(compiledStatement);
//        }
//        
//        sqlite3_close(database);
//        
//    }
//    
//    return array;
//    
//}
//
//- (int) GetTotalUpcomingVenuesCount
//{
//    int count = 0;
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        const char* sqlStatement = "SELECT COUNT(*) FROM tbl_StepOnOff where CurrentStatus = '1'";
//        sqlite3_stmt *statement;
//        
//        if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
//        {
//            //Loop through all the returned rows (should be just one)
//            while( sqlite3_step(statement) == SQLITE_ROW )
//            {
//                count = sqlite3_column_int(statement, 0);
//            }
//        }
//        
//        // Finalize and close database.
//        sqlite3_finalize(statement);
//        sqlite3_close(database);
//    }
//    
//    return count;
//}
//
//
//#pragma mark - tbl_GalleryImages
//- (BOOL) insertALLPhotoDetailsFirstTime_tbl_GalleryImages:(NSArray*)arrayData
//{
//    
//    
//    //const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        char* errorMessage;
//        sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &errorMessage);
//        
//        
//        for (int i =0; i <[arrayData count]; i++)
//        {
//            NSMutableArray *array = [arrayData objectAtIndex:i];
//
//            NSString *query=[NSString stringWithFormat:@"insert into tbl_GalleryImages (filename,venue_name,venue_id,photo_taken) values (\"%@\", \"%@\",\"%@\", \"%@\")",[array valueForKey:@"filename"],[array valueForKey:@"name"],[array valueForKey:@"venue_id"],[array valueForKey:@"photo_taken"]];
//            
//            if (sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//            {
//                NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
//                return NO;
//            }
//            else
//            {
//                NSLog(@"Success");
//            }
//            
//        }
//        sqlite3_exec(database, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
//    }
//    
//    NSLog(@"success dfdsf");
//    
//    return YES;
//}
//
//
//- (BOOL)insertPhotoDetails_tbl_GalleryImages:(NSMutableDictionary*)arrayData
//{
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        char* errorMessage;
//        
//            NSString *query=[NSString stringWithFormat:@"insert into tbl_GalleryImages (filename,venue_name,venue_id,photo_taken) values (\"%@\", \"%@\",\"%@\", \"%@\")",[arrayData valueForKey:@"filename"],[arrayData valueForKey:@"name"],[arrayData valueForKey:@"venue_id"],[arrayData valueForKey:@"photo_taken"]];
//            
//            if (sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMessage) != SQLITE_OK)
//            {
//                NSLog(@"DB Error. category transacation '%s'", sqlite3_errmsg(database));
//                return NO;
//            }
//            else
//            {
//                NSLog(@"Success");
//            }
//            
//    }
//    
//    NSLog(@"success dfdsf");
//    
//    return YES;
//}
//
//- (NSMutableArray*)getPhotoDetailsFrom_tbl_GalleryImages
//{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    
//    // Setup the database object
//    sqlite3 *database;
//    
//    // Open the database from the users filessytem
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        // Setup the SQL Statement and compile it for faster access
//        //Where PlaceDistance  BETWEEN '0' AND '100'
//        //SQLIte Statement
//        
//        //order by PlaceDistance asc
//        NSString *sqlStatement_userInfo =[NSString stringWithFormat:@"Select * from tbl_GalleryImages"];
//        
//        sqlite3_stmt *compiledStatement;
//        
//        
//        if(sqlite3_prepare_v2(database, [sqlStatement_userInfo UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
//        {
//            
//            // Loop through the results and add them to the feeds array
//            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
//                // Init the Data Dictionary
//                NSMutableDictionary *dataDictionary=[[NSMutableDictionary alloc] init];
//                
//                NSString *ID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                NSString *filename = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
//                NSString *venue_name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
//                NSString *venue_id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
//                NSString *photo_taken = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
//                
//                
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",ID] forKey:@"ID"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",filename] forKey:@"filename"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",venue_name] forKey:@"venue_name"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",venue_id] forKey:@"venue_id"];
//                [dataDictionary setObject:[NSString stringWithFormat:@"%@",photo_taken] forKey:@"photo_taken"];
//                [array addObject:dataDictionary];
//            }
//            
//            sqlite3_finalize(compiledStatement);
//            
//        }
//        else
//        {
//            NSLog(@"No Data Found");
//        }
//        
//        // Release the compiled statement from memory
//    }
//    
//    // sqlite3_close(database);
//    
//    return array;
//}
//
//- (void) deletePhotoDetails_tbl_GalleryImages:(NSString *)fileName
//{
//    
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//         NSString *insertSQL = [NSString stringWithFormat:@"delete from tbl_GalleryImages WHERE filename =\"%@\"",fileName];
//        
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE)
//        {
//            NSLog(@"delete success");
//            
//            sqlite3_finalize(statement);
//            // sqlite3_close(database);
//        }
//        else {
//            NSLog(@"failed to delete");
//        }
//    }
//    
//}
//
//#pragma mark - clearing DB 
//
//- (NSMutableArray*)getAllTableNameList
//{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    
//    // Setup the database object
//    sqlite3 *database;
//    
//    // Open the database from the users filessytem
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        // Setup the SQL Statement and compile it for faster access
//        //Where PlaceDistance  BETWEEN '0' AND '100'
//        //SQLIte Statement
//        //order by PlaceDistance asc
//        NSString *sqlStatement_userInfo =[NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type=\'table\'"];
//        sqlite3_stmt *compiledStatement;
//        if(sqlite3_prepare_v2(database, [sqlStatement_userInfo UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK)
//        {
//            // Loop through the results and add them to the feeds array
//            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
//            {
////                NSString *tableName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
//                NSString *tableName = [NSString stringWithCString:(const char *)sqlite3_column_text(compiledStatement, 0)encoding:NSUTF8StringEncoding];
//                [array addObject:tableName];
//            }
//            sqlite3_finalize(compiledStatement);
//        }
//        else
//        {
//            NSLog(@"No Data Found");
//        }
//        
//        // Release the compiled statement from memory
//    }
//    
//    // sqlite3_close(database);
//    
//    return array;
//}
//
//- (void) deleteAllTablesData:(NSString *)fileName
//{
//    
//    if (sqlite3_open_v2([databasePath UTF8String], &(database), SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
//    {
//        NSString *insertSQL = [NSString stringWithFormat:@"delete from \"%@\"",fileName];
//        
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE)
//        {
//            NSLog(@"delete success");
//            
//            sqlite3_finalize(statement);
//            // sqlite3_close(database);
//        }
//        else
//        {
//            NSLog(@"failed to delete");
//        }
//    }
//    
//}


@end
