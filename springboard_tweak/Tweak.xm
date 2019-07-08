// 去除通知红色泡泡
// 拦截系统通知信息

// 通知泡泡类
%hook SBIconBadgeView
- (id)init
{
	return nil;
}
%end

%hook SBIconParallaxBadgeView
- (id)init
{
	return nil;
}
%end

// 锁屏管理类
@interface SBLockScreenManager
@end

// %hook SBLockScreenManager
// - (void)lockUIFromSource:(int)arg1 withOptions:(id)arg2
// {
//     %orig;
//     UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示"
// 													   message:@"测试"
// 													  delegate:nil 
// 											 cancelButtonTitle:@"确定"
// 						    				 otherButtonTitles:nil, nil];
//     [alertView show];
// }
// %end

// 通知信息列表VC
@interface NCNotificationCombinedListViewController
- (id)notificationPriorityList;
- (id)notificationSectionList;
- (id)notificationMissedList;
@end

@interface NCNotificationPriorityList
// [NSOrderedSet orderedSetWithArray:@[#"<NCNotificationListNotificationRequestItem: 0x283024450>"]]]
- (id)notificationListItems;
@end

@interface NCNotificationListNotificationRequestItem
- (id)notificationRequest;
@end

@interface NCNotificationRequest
// @"com.tencent.xin"
- (id)sectionIdentifier; 
// @"TextMessage"
- (id)categoryIdentifier;
/*
@{
    "launchImage": "",
    "remoteNotification":@{
        "t": "1562079049",
        "id": "8424473448211880636",
        "aps":@{
            "badge": 1,
            "alert":@{
                "title": "coiioo",
                "body": "fdd"
            },
            "category": "TextMessage",
            "sound": "in.caf"
        },
        "u": "wxid_vjrk1dyx1m1m22",
        "m": "1",
        "isreport": 0,
        "cmd": "104",
        "showtype": 1
    },
    "notificationType": "AppNotificationRemote",
}
*/
- (id)context;
@end

%hook SBDashBoardCombinedListViewController

- (void)notificationListViewControllerIsUpdatingContent:(id)arg1
{
	%orig;
	NCNotificationCombinedListViewController *vc = arg1;
	NCNotificationPriorityList *priorityList = [vc notificationPriorityList];
	NSOrderedSet *orderset = [priorityList notificationListItems];
	// 取数组的第一个
	NCNotificationListNotificationRequestItem *item = orderset.firstObject;
	NCNotificationRequest *request = [item notificationRequest];
	NSString *appID = [request sectionIdentifier];
	NSString *type = [request categoryIdentifier];
	NSDictionary *context = [request context];
	NSMutableDictionary *contextDic = [NSMutableDictionary dictionaryWithDictionary:context];
	[contextDic setValue:@"内容太长已经去除" forKey:@"UNBulletinContextArchivedUserNotification"];
    if (appID){
        // 消息转发
	    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示"
												      	   message:[NSString stringWithFormat:@"AppID:%@\n通知类型:%@\n通知内容:%@\n",appID,type,contextDic]
												 	      delegate:nil 
											     cancelButtonTitle:@"确定"
											     otherButtonTitles:nil, nil];
	    [alertView show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES]; 
        });
    }
}

%end
