//
//  NSIndexSet+Convenience.m
//  FitRunning
//
//  Created by lilingang on 15/10/12.
//  Copyright © 2015年 LiLingang. All rights reserved.
//

#import "NSIndexSet+Convenience.h"

@implementation NSIndexSet (Convenience)

- (NSArray *)ddIndexPathsFromIndexesWithSection:(NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}

@end
