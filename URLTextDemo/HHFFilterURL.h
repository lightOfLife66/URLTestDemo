//
//  HHFFilterURL.h
//  URLTextDemo
//
//  Created by 袁涛 on 2019/5/14.
//  Copyright © 2019 Y_T. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^filterURLSuccessBlock)(NSInteger index,NSString *url);
typedef void(^filterURLFailBlock)(void);
NS_ASSUME_NONNULL_BEGIN

@interface HHFFilterURL : NSObject
@property (strong, nonatomic) NSArray <NSString *>	*URLs;
@property (copy, nonatomic) filterURLSuccessBlock 	successBlock;
@property (copy, nonatomic) filterURLFailBlock		failBlock;


/**
 是否自动停止  默认为yes
 */
@property (assign, nonatomic) BOOL					atomicStop;

+ (void)CleanMemoryCache;
@end


@interface HHFNetWork : NSObject
@property (copy, nonatomic) void(^success)(NSURLSessionDataTask *dataTask ,id requestObject) ;
@property (copy, nonatomic) void(^failure)(NSURLSessionDataTask *dataTask, NSError *error);

- (void)GET:(NSString *)URLstring;
@end

NS_ASSUME_NONNULL_END
