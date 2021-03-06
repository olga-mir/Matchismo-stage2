//
//  Card.h
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : NSObject <NSCopying>

@property (strong, nonatomic)NSString *contents;

@property (nonatomic, getter = isChosen) BOOL chosen;
@property (nonatomic, getter = isMatched) BOOL matched;

- (instancetype)initWithCard:(Card *)card;

// virtual method - cards matched depending on their nature
- (int)match:(NSArray *)otherCards;


@end