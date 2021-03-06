/*
 * Author: Jumbo <hi@itzhangbao.com>
 *
 * Copyright (c) 2012-2021 @itzhangbao.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBCrasherModel : NSObject

/**
 * Crash name
 */
@property (nonatomic, copy) NSString *name;

/**
 * Crash stack information
 */
@property (nonatomic, strong) NSArray *stacks;

/**
 * Cause of collapse
 */
@property (nonatomic, copy) NSString *reason;

/**
 * crash time. of 1000
 */
@property (nonatomic, copy) NSString *timestamp;

// device info
@property (nonatomic, copy) NSString * bundleId;
@property (nonatomic, copy) NSString * appVersion;
@property (nonatomic, copy) NSString * buildVersion;

/*
 * The model to dictionary.
 */
- (NSDictionary *)toDictionary;

/**
 * The dictionary to model.
 */
+ (ZBCrasherModel *)modelWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
