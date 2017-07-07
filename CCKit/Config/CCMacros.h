//
//  CCMacros.h
//  CCKit
//
//  Created by CC on 2017/7/7.
//  Copyright © 2017年 CCtest. All rights reserved.
//

#ifndef CCMacros_h
#define CCMacros_h


/** 快速迭代方法 **/
static inline void cc_dispatch_apply(int count, void (^block)(size_t index))
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(count, queue, block);
}

/** 从现在返回dispatch_time延迟。 **/
static inline dispatch_time_t cc_dispatch_time_delay(NSTimeInterval second)
{
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC));
}

/** 从现在返回dispatch_wall_time延迟。 **/
static inline dispatch_time_t cc_dispatch_walltime_delay(NSTimeInterval second)
{
    return dispatch_walltime(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC));
}

/** 在进队列上提交延时执行的快，并立即返回。**/
static inline void cc_dispatch_after(NSTimeInterval second, void (^block)())
{
    dispatch_after(cc_dispatch_walltime_delay(second), dispatch_get_main_queue(), block);
}

/** 是否在主队列/线程中。 **/
static inline bool cc_dispatch_is_main_queue()
{
    return pthread_main_np() != 0;
}

/** 在主队列上提交用于异步执行的块 **/
static inline void cc_dispatch_async_on_global_queue(void (^block)())
{
    dispatch_async(dispatch_get_global_queue(0, 0), block);
}

/** 在主队列上提交用于异步执行的块，并立即返回。**/
static inline void cc_dispatch_async_on_main_queue(void (^block)())
{
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

/** 在主队列上提交执行块，并等待直到块完成。*/
static inline void cc_dispatch_sync_on_main_queue(void (^block)())
{
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}


#endif /* CCMacros_h */
