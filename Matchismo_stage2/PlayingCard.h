//
//  PlayingCard.h
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "Card.h"

@interface PlayingCard : Card <NSCopying>

@property (strong, nonatomic) NSString *suit;
@property (nonatomic) NSUInteger rank;

+ (NSUInteger)maxRank;
+ (NSArray *)validSuits;

@end