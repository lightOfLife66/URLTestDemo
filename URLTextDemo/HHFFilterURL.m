//
//  HHFFilterURL.m
//  URLTextDemo
//
//  Created by 袁涛 on 2019/5/14.
//  Copyright © 2019 Y_T. All rights reserved.
//

#import "HHFFilterURL.h"


/**
 网络请求类
 */
@interface HHFNetWork ()
@property (copy, nonatomic) NSURLSessionDataTask *dataTask;
@end

@implementation HHFNetWork

- (void)GET:(NSString *)URLstring  {
    NSURL *url = [NSURL URLWithString:URLstring];
    
    //设置请求地址
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //设置请求方式
    request.HTTPMethod = @"GET";
    
    //设置请求参数
    request.HTTPBody = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    //关于parameters是NSDictionary拼接后的NSString.关于拼接看后面拼接方法说明
    
    
    //设置请求session
    NSURLSession *session = [NSURLSession sharedSession];
    
    //设置网络请求的返回接收器
    _dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (error) {
                if (self.failure) {
                    self.failure(self.dataTask,error);
                }
            }else{
                self.success(self.dataTask,data);
            }
        });
    }];
    //开始请求
    [_dataTask resume];
}

@end


@interface HHFFilterURL ()

/**
 当前进行到第几个
 */
@property (assign, nonatomic) NSInteger index;
/**
 是否已经返回过成功
 */
@property (assign, nonatomic) BOOL finish;

@property (strong, nonatomic) HHFNetWork  *network;
@end

@implementation HHFFilterURL
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self Initialize];
    }
    return self;
}

- (void)dealloc {

}

#pragma mark - Initialize
- (void)Initialize {
    _atomicStop = YES;
}

#pragma mark - setter
- (void)setURLs:(NSArray<NSString *> *)URLs {
    _URLs = URLs;
    if (URLs.count == 0) {
        if (self.failBlock) {
            self.failBlock();
            return;
        }
    }
    _finish = NO;
    _index = 0;
    
    [self filterURL:_URLs.firstObject];
}

- (void)filterURL:(NSString *)url {
    //当self.URLs 数量小于 _index 终止递归
    if (self.URLs.count <= _index) {
        return;
    }
    //获取可用url缓存
    if (nil != [[[self class] filterSuccessDict] objectForKey:url]) {
        //判断是否已经返回成功
        if (!self.finish) {
        	self.finish = YES;
           	self.successBlock(_index, url);
        }
        //是否自动停止请求 如果_atomicStop == NO 不会自动停止递归
        if (!_atomicStop) {
            _index += 1;
            [self filterURL:[self getURLForIndex:_index]];
        }
        return;
    }
    //获取不可以url 缓存
    if (nil != [[[self class] filterFailDict] objectForKey:url]) {
        //并且判断是是否返回过可用的URL  和 是否已经遍历到最后最后一个
        //如果吻合  f返回失败操作
        _index += 1;
        if (!self.finish &&
            self.URLs.count == _index){
            self.failBlock();
            return;
        }
        //继续递归
        
        [self filterURL:[self getURLForIndex:_index]];
        return;
    }
    
    //发送请求网络请求 判断当前URL是否可用
    _network = [[HHFNetWork alloc] init];
    __weak typeof(self) weakself = self;
    _network.success = ^(NSURLSessionDataTask *dataTask, id  _Nonnull requestObject) {
        //获取当前请求的url
        __strong typeof(weakself) strongself = weakself;
        NSString *url = dataTask.currentRequest.URL.absoluteString;
        //加入全局缓存
        [[[strongself class] filterSuccessDict] setObject:@"1" forKey:url];
        //判断是否已经 返回过可用url
        if (!strongself.finish) {
            strongself.successBlock(weakself.index, url);
        }
        //weakself.finish 置为YES
        strongself.finish = YES;
        //判断当前是否制动终止 遍历 为NO 自动停止遍历
        if (strongself.atomicStop == NO) {
            strongself.index += 1;
            [strongself filterURL:[weakself getURLForIndex:weakself.index]];
        }
    };
    
    _network.failure = ^(NSURLSessionDataTask *dataTask, NSError * _Nonnull error) {
		//缓存不可用的URL
        __strong typeof(weakself) strongself = weakself;
         strongself.index += 1;
        [[[weakself class] filterFailDict] setObject:@"0" forKey:dataTask.currentRequest.URL.absoluteString];
        
        //并且判断是是否返回过可用的URL  和 是否已经遍历到最后最后一个
        //如果吻合  返回失败操作
        if (strongself.URLs.count == weakself.index &&
            !strongself.finish) {
            strongself.failBlock();
            return ;
        }
        //继续递归
       
        [strongself filterURL:[weakself getURLForIndex:weakself.index]];
    };
    
    [_network GET:url];
    
}

- (NSString *)getURLForIndex:(NSInteger)index {
    if (_index >= self.URLs.count) {
        return @"";
    }
    
    return self.URLs[_index];
}



#pragma mark - getter


#pragma mark - class Method
/** 不可用URL缓存 */
static NSMutableDictionary *_HHFFilterFailDict = nil;
+ (NSMutableDictionary *)filterFailDict {
    if(nil ==  _HHFFilterFailDict) {
        _HHFFilterFailDict = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return _HHFFilterFailDict;
}
/** 可用URL缓存 */
static NSMutableDictionary *_HHFFilterSuccessDict = nil;
+ (NSMutableDictionary *)filterSuccessDict {
    if(nil ==  _HHFFilterSuccessDict) {
        _HHFFilterSuccessDict = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return _HHFFilterSuccessDict;
}
/** 清除缓存 */
+ (void)CleanMemoryCache {
    [_HHFFilterSuccessDict removeAllObjects];
    [_HHFFilterFailDict removeAllObjects];
}

@end







