//
//  DBManager.h
//  StepOne
//
//  Created by adnan on 22/02/2016.
//  Copyright © 2016 Limitless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject
{
    NSString *databasePath;
}

+ (DBManager*)getSharedInstance;
+ (void)resetSharedInstance;

- (BOOL)createDB;

- (BOOL)saveDataIn_tbl_Settings;
- (NSMutableDictionary*)getSettingsDetails;
- (NSMutableArray*)getCheckInPlaceIdAndNames;
- (NSMutableArray*)getCheckInAndCheckOutTime;

- (void)delete_tbl_FBProfile;
- (BOOL)insertFBdetails:(NSMutableDictionary*)dicUserDetail;
- (BOOL)updateFBdetails:(NSMutableDictionary*)dicUserDetail;
- (void)updateFBDetailByKey:(NSString *)key Value:(NSString *)valu;
- (NSMutableDictionary*) getFBProfile;
- (void)updateSettingByKey:(NSString *)key Value:(NSString *)valu;
- (BOOL)updateSettingsDetails:(NSMutableDictionary*)updateArray;

- (BOOL)saveDataIn_tbl_NearbyPlaces:(NSArray*)arrayData;
- (BOOL)saveSettingsFromServer:(NSArray *)arrSettings;
- (BOOL)saveChatFriendList:(NSArray *)arrChatFriendList;
- (void)deleteChatFriendList;
- (void)deleteChatRoomHistory:(NSString*)friend_id;
- (void)deleteChatRoomForAllUsersToGetChatLatestHistory;
//- (BOOL)saveOnlineStatusList:(NSArray *)arrOnlineStatusList;
- (void)saveOnlineStatusList:(NSDictionary *)dictOnlineStatusList;
- (void)insertOnlineStatusList:(NSDictionary *)dictOnlineStatusList;
- (NSMutableArray*)getOnlineStatusList:(NSString*)facebook_id;
- (NSMutableArray*)getAllOnlineStatusList;
- (void)deleteOnlineStatusList;
- (void)saveChatRoomList:(NSArray *)arrChatFriendList FrindList:(NSString*)FriendID;
- (void)SaveChatRoomListAfterOldRecordDeleted:(NSArray *)arrChatFriendList FrindList:(NSString*)FriendID;
- (NSMutableArray*)getAllChatFriendList;
- (NSMutableArray*)getAllChatRoomList:(NSString*)friend_id;
- (NSMutableArray*)getAllUnreadChatMessages:(NSString*)facebook_id;
- (NSMutableArray*)getAllUnreadChatMessages;
- (BOOL)saveAllUnreadChatMessages:(NSArray *)arrUnreadChatMessagesList;
- (void)deleteAlreadyReadMessages:(NSString*)facebook_id;
- (void)deleteAllRowsIn_tbl_NearbyPlaces;
- (NSMutableArray*)getAllDetailsFrom_tbl_NearbyPlaces;

- (BOOL)insertFirstTimeIn_tbl_CheckInPlaces:(NSArray*)arrayData;
- (BOOL)insertIn_tbl_CheckInPlaces:(NSMutableDictionary*)arrayData;
- (NSMutableArray*)getAllDetailsFrom_tbl_CheckInPlaces;
- (NSMutableArray*)getCheckInPlaceByPlaceId:(NSString *)placeID;
- (BOOL)updateCheckOut_tbl_CheckInPlaces:(NSMutableDictionary*)arrayData;
- (NSMutableDictionary*)getLastInsertedRowFrom_tbl_CheckInPlaces;

- (BOOL)updateCheckOut_tbl_CheckInTimeInOut:(NSMutableDictionary*)arrayData;
- (NSMutableArray*)getAllDetails_tbl_CheckInTimeInOut : (NSString*)PlaceID;

- (BOOL)insertIn_tbl_StepOnOff:(NSMutableDictionary*)arrayData;
- (BOOL)CheckValueExit_tbl_StepOnOff:(NSString*)PlaceID;
- (void)deleteStepOffRow_tbl_StepOnOff:(NSString *)PlaceID;
- (void)deleteOlderThenOneDayRow_tbl_StepOnOff;
- (NSMutableArray*)getAllDetailsFrom_tbl_StepOnOff;
- (BOOL)insertAllUpcomingVenues_tbl_StepOnOff:(NSArray*)arrayData;
- (NSMutableArray*)getStepOnPlaceDetail_tbl_StepOnOff:(NSString*)PlaceID;
- (int) GetTotalUpcomingVenuesCount;
- (void) deleteCheckInRow_tbl_StepOnOff;
- (NSMutableArray*)getCheckInPlaceByCurrentStatus;

- (BOOL)insertPhotoDetails_tbl_GalleryImages:(NSMutableDictionary*)arrayData;
- (NSMutableArray*)getPhotoDetailsFrom_tbl_GalleryImages;
- (void) deletePhotoDetails_tbl_GalleryImages:(NSString *)fileName;
- (BOOL) insertALLPhotoDetailsFirstTime_tbl_GalleryImages:(NSArray*)arrayData;

- (NSMutableArray*)getAllTableNameList;
- (void) deleteAllTablesData:(NSString *)fileName;


- (BOOL)saveDataInLoginTable;
- (BOOL)saveDataInRSSFeedsTable;
- (BOOL)saveAllRSSFeeds:(NSArray *)arrRSSFeeds;
- (NSMutableArray*)getAllRSSFeeds;


@end
