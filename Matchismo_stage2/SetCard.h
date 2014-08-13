//
//  SetCard.h
//  Matchismo_stage2
//
//  SetCard class implements the logic of a card in Set game as described on the Wikipedia site:
//  http://en.wikipedia.org/wiki/Set_(game)
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "Card.h"


@interface SetCard : Card

@property (strong, nonatomic)NSString *contents;

@property (nonatomic) NSUInteger rank;            // 1, 2 or 3
@property (strong, nonatomic) NSString *color;    // green, red or purple (not UIColor because it is Model)
@property (strong, nonatomic) NSString *filling;  // solid, striped or unfilled
@property (strong, nonatomic) NSString *shape;    // squiggles, diamonds or ovals


+ (NSUInteger)maxRank;
+ (NSArray *)validColors;
+ (NSArray *)validFillings;
+ (NSArray *)validShapes;


@end
