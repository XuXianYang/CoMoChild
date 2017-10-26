#import "BSHttpRequest.h"
#import <AFNetworking.h>
#import "AppDelegate.h"

@interface BSHttpRequest ()

@end


@implementation BSHttpRequest
+ (void)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    // 获得网络管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:URLString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject isKindOfClass:[NSData class]]) {
            success(responseObject);
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString*codeString=objString[@"code"];
            
            if(codeString.intValue==4003)
            {
                [(AppDelegate*)[UIApplication sharedApplication].delegate setUpLogOutAppAlert];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
    
//        [manager GET:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            if ([responseObject isKindOfClass:[NSData class]]) {
//                success(responseObject);
//            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            failure(error);
//        }];
}

+ (void)POST:(NSString *)URLString parameters:(id)parameters success:(void(^)(id responseObject))success failure:(void (^)(NSError * error))failure
{
   AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    
//    //如果报接受类型不一致请替换一致text/html或别的
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain",@"application/json",nil];
  
    [manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject isKindOfClass:[NSData class]]) {
            success(responseObject);
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString*codeString=objString[@"code"];
            
            if(codeString.intValue==4003)
            {
                [(AppDelegate*)[UIApplication sharedApplication].delegate setUpLogOutAppAlert];
            }

        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];

    
//    [manager POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            if ([responseObject isKindOfClass:[NSData class]]) {
//                success(responseObject);
//            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            failure(error);
//        }];
    
}
+ (void)DELETE:(NSString *)URLString parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    //    //如果报接受类型不一致请替换一致text/html或别的
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain",@"application/json",nil];
    
    [manager DELETE:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            success(responseObject);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        failure(error);
    }];

    
}
+ (void)archiverObject:(id)object ByKey:(NSString *)key WithPath:(NSString *)path
{
    //初始化存储对象信息的data
    NSMutableData *data = [NSMutableData data];
    //创建归档工具对象
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    //开始归档
    [archiver encodeObject:object forKey:key];
    //结束归档
    [archiver finishEncoding];
    //写入本地
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
    NSString *destPath = [[docPath stringByAppendingPathComponent:@"Caches"] stringByAppendingPathComponent:path];
    
    [data writeToFile:destPath atomically:YES];
}

+ (id)unarchiverObjectByKey:(NSString *)key WithPath:(NSString *)path
{
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
    NSString *destPath = [[docPath stringByAppendingPathComponent:@"Caches"] stringByAppendingPathComponent:path];
    NSData *data = [NSData dataWithContentsOfFile:destPath];
    //创建反归档对象
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    //接收反归档得到的对象
    id object = [unarchiver decodeObjectForKey:key];
    return object;
}

@end
