//
//  AppDelegate.h
//  CommentDemo
//
//  Created by tanlu on 2019/1/9.
//  Copyright © 2019年 tanlu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

