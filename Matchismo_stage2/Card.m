//
//  Card.m
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "Card.h"
#import "Utils.h"

@implementation Card

- (NSString *)description
{
  return [NSString stringWithFormat:@"Card contents: %@",  self.contents];
}

// NOTE:
// In general the base class Card should have 'contents' property and match method
// However in this particular assignment we only have two games that have very different contents and match rules
// Therefore, due to time constraints I'm not going to implement this.
- (int)match:(NSArray *)otherCards
{
  mustOverride();
}

@end