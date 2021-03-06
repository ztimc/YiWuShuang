//
//  ApiManager.m
//  YiWuShuang
//
//  Created by 黄 on 2020/4/4.
//  Copyright © 2020 huang. All rights reserved.
//

#import "ApiManager.h"
#import "NSDictionary+YYAdd.h"
#import "NSObject+YYModel.h"
#import "UserSession.h"
#import "YKAddition.h"
//发送验证码
static NSString *sendCodeUrl = @"/api/sms/send";
//检查 token
static NSString *checkTokenUrl = @"/api/token/check";
//刷新 token
static NSString *refreshTokenUrl = @"/api/token/refresh";
//登录
static NSString *loginUrl = @"/api/user/login";
//获取组织列表
static NSString *getOrigUrl = @"/api/team/list";
//获取部门列表
static NSString *getPartsUrl = @"/api/team/getDepartsList";
//创建组织
static NSString *getOrizIDUrl = @"/api/team/create";
//创建部门
static NSString *createPartUrl = @"/api/team/department";
//获取组织分类
static NSString *teamNatureListUrl = @"/api/category/team";
//加入组织
static NSString *joinTeam = @"/api/team/add";
//成员列表
static NSString *memberList = @"/api/team/departs";
//添加成员、学员
static NSString *addMemberUrl = @"/api/team/user";

static NSString *debugHost = @"https://test.yiwushuang.cn";
static NSString *releaseHost = @"https://www.yiwushuang.cn";
@implementation ApiManager
+ (instancetype)manager {
    static ApiManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ApiManager alloc] init];
    });
    return manager;
}

- (NSString *)getHost {
#ifdef DEBUG
    return debugHost;
#endif
    return releaseHost;
}

- (void)sendMessageWithPhoneNumber:(NSString *)phoneNumber success:(void (^)(BaseModel *baseModel))success failure:(void (^)(NSError *error))failure; {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:phoneNumber forKey:@"mobile"];
    
    [self requestWithApi:sendCodeUrl params:params success:success failure:failure];
}

- (void)checkTokenSuccess:(void (^)(BaseModel *baseModel))success
                  failure:(void (^)(NSError *error))failure {
    [self requestWithApi:checkTokenUrl params:nil success:success failure:failure];
}

//刷新 token
- (void)refreshTokenSuccess:(void (^)(BaseModel *baseModel))success
                    failure:(void (^)(NSError *error))failure {
    [self requestWithApi:refreshTokenUrl params:nil success:success failure:failure];
}

- (void)loginWithPhoneNumber:(NSString *)phoneNumber code:(NSString *)code success:(void (^)(BaseModel *baseModel))success failure:(void (^)(NSError *error))failure {
    if (!phoneNumber || !code) {
        if (failure) {
            failure(nil);
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:phoneNumber forKey:@"mobile"];
    [params setValue:code forKey:@"captcha"];
    [self requestWithApi:loginUrl params:params success:success failure:failure];
}

- (void) getOrganization:(NSString *)token success:(void (^)(BaseModel *baseModel))success failure:(void (^)(NSError *error))failure {
    if (token.length == 0) {
        if (failure) {
            failure(nil);
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:token forKey:@"token"];
    [self requestWithApi:getOrigUrl params:params success:success failure:failure];
}

- (void) getPartsWithTeamID:(NSString *)teamID
                    success:(void (^)(BaseModel *baseModel))success
                    failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:teamID forKey:@"team_id"];
    [self requestWithApi:getPartsUrl params:params success:success failure:failure];
}

- (void) getNatureList:(NSString *)token
               success:(void (^)(BaseModel *baseModel))success
               failure:(void (^)(NSError *error))failure {
    if (token.length == 0) {
        if (failure) {
            failure(nil);
        }
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:token forKey:@"token"];
    [self requestWithApi:teamNatureListUrl params:params success:success failure:failure];
}

- (void) getOrganizationID:(NSString *)token
                   success:(void (^)(BaseModel *baseModel))success
                   failure:(void (^)(NSError *error))failure {
    if (token.length == 0) {
        if (failure) {
            failure(nil);
        }
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:token forKey:@"token"];
    [params yk_setValue:@"base" forKey:@"event"];
    [self requestWithApi:getOrizIDUrl params:params success:success failure:failure];
}


- (void) fillOrganizationInfo:(NSString *)token
                       teamId:(NSString *)teamId
                        catId:(NSString *)catId
                      educate:(NSString *)educate
                      manager:(NSString *)manager
                         name:(NSString *)name
                      success:(void (^)(BaseModel *baseModel))success
                      failure:(void (^)(NSError *error))failure {
    if (token.length == 0) {
        if (failure) {
            failure(nil);
        }
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    [params setValue:token forKey:@"token"];
    [params yk_setValue:@"info" forKey:@"event"];
    [params yk_setValue:teamId forKey:@"team_id"];
    [params yk_setValue:catId forKey:@"cat_id"];
    [params yk_setValue:educate forKey:@"educate"];
    [params yk_setValue:manager forKey:@"manager"];
    [params yk_setValue:name forKey:@"name"];
    
    [self requestWithApi:getOrizIDUrl params:params success:success failure:failure];
}

- (void) joinTeam:(NSString *)token
           teamId:(NSString *)teamId
             name:(NSString *)name
          success:(void (^)(BaseModel *baseModel))success
          failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    [params setValue:token forKey:@"token"];
    [params yk_setValue:teamId forKey:@"team_id"];
    [params yk_setValue:name forKey:@"name"];
    [self requestWithApi:loginUrl params:params success:success failure:failure];
}

- (void) createPartWithTeamID:(NSString *)teamID
                     teamName:(NSString *)teamName
                    managerID:(NSString *)managerID
                      success:(void (^)(BaseModel *baseModel))success
                      failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *param = @{}.mutableCopy;
    [param yk_setValue:teamID forKey:@"team_id"];
    [param yk_setValue:teamName forKey:@"name"];
    [param yk_setValue:managerID forKey:@"manager_id"];
    [self requestWithApi:createPartUrl params:param success:success failure:failure];
}

- (void) memberList:(NSString *)teamId
            success:(void (^)(BaseModel *baseModel))success
            failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *params = @{}.mutableCopy;
    [params yk_setValue:teamId forKey:@"team_id"];
    [self requestWithApi:memberList params:params success:success failure:failure];
}

- (void)addMemberWithTeamId:(NSString *)teamId partId:(NSString *)part_id name:(NSString *)name mobild:(NSString *)mobile type:(NSString *)type isManager:(BOOL)isManager success:(void (^)(BaseModel * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params yk_setValue:teamId forKey:@"team_id"];
    [params yk_setValue:part_id forKey:@"part_id"];
    [params yk_setValue:name forKey:@"name"];
    [params yk_setValue:mobile forKey:@"mobile"];
    [params yk_setValue:type forKey:@"type"];
    if (isManager) {
        [params yk_setValue:@1 forKey:@"is_manager"];
    }else{
        [params yk_setValue:@0 forKey:@"is_manager"];
    }
    [self requestWithApi:addMemberUrl params:params success:success failure:failure];
}

#pragma mark - basic
- (void)requestWithApi:(NSString *)api params:(NSDictionary *)params success:(void (^)(BaseModel *baseModel))success failure:(void (^)(NSError *error))failure {
    AFHTTPSessionManager *httpManager = [AFHTTPSessionManager manager];
    NSString *host = releaseHost;
#ifdef DEBUG
    host = debugHost;
#endif
    NSString *url = [host stringByAppendingString:api];
    NSMutableDictionary *paramter = @{}.mutableCopy;
    [paramter yk_setValue:[UserSession session].currentUser.token forKey:@"token"];
    [paramter addEntriesFromDictionary:params];
    [httpManager POST:url parameters:paramter headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        BaseModel *model = [[BaseModel alloc] initWithDictionary:responseObject];
        if (success) {
            success(model);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}
@end
